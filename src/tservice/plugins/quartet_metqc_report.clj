(ns tservice.plugins.quartet-metqc-report
  (:require [clojure.data.json :as json]
            [clojure.spec.alpha :as s]
            [spec-tools.core :as st]
            [clojure.tools.logging :as log]
            [tservice.lib.files :as ff]
            [tservice.api.config :refer [add-env-to-path]]
            [tservice.lib.fs :as fs-lib]
            [tservice.vendor.multiqc :as mq]
            [tservice.plugins.quartet-metqc-report.metqc :as metqc]
            [tservice.api.task :refer [make-events-init publish-event! make-plugin-metadata create-task! update-process!]]))

;;; ------------------------------------------------ Event Specs ------------------------------------------------
(s/def ::metadata_file
  (st/spec
   {:spec                (s/and string? #(re-matches #"^[a-zA-Z0-9]+:\/\/(\/|\.\/)[a-zA-Z0-9_]+.*" %))
    :type                :string
    :description         "File path for metadata file, such as file:///xxx/xxx/metadata.csv"
    :swagger/default     nil
    :reason              "The filepath must be string."}))

(s/def ::data_file
  (st/spec
   {:spec                (s/and string? #(re-matches #"^[a-zA-Z0-9]+:\/\/(\/|\.\/)[a-zA-Z0-9_]+.*" %))
    :type                :string
    :description         "File path for metabolomics profiled data, such as file:///xxx/xxx/data.csv"
    :swagger/default     nil
    :reason              "The filepath must be string."}))

(s/def ::name
  (st/spec
   {:spec                string?
    :type                :string
    :description         "The name of the report"
    :swagger/default     ""
    :reason              "Not a valid name"}))

(s/def ::description
  (st/spec
   {:spec                string?
    :type                :string
    :description         "Description of the report"
    :swagger/default     ""
    :reason              "Not a valid description."}))

(def quartet-metqc-report-params-body
  "A spec for the body parameters."
  (s/keys :req-un [::name ::data_file ::metadata_file]
          :opt-un [::description]))

;;; ------------------------------------------------ Event Metadata ------------------------------------------------
(def metadata
  (make-plugin-metadata
   {:name "quartet-metqc-report"
    :summary "Visualizes Quality Control(QC) results from metabolomics data for Quartet Project."
    :params-schema quartet-metqc-report-params-body
    :handler (fn [{:keys [name data_file metadata_file description owner plugin-context]
                   :or {description (format "Quality control report for %s" name)}
                   :as payload}]
               (let [payload (merge {:description description} payload)
                     data-file (metqc/correct-filepath data_file)
                     metadata-file (metqc/correct-filepath metadata_file)
                     workdir (metqc/dirname data-file)
                     log-path (fs-lib/join-paths workdir "log")
                     response {:report (format "%s/multiqc_report.html" workdir)
                               :log log-path
                               :response-type :data2report}
                     task-id (create-task! {:name           name
                                            :description    description
                                            :payload        payload
                                            :owner          owner
                                            :plugin-name    "quartet-metqc-report"
                                            :plugin-type    "ReportPlugin"
                                            :plugin-version (:plugin-version plugin-context)
                                            :response       response})
                     result-dir (fs-lib/join-paths workdir "results")]
                 (fs-lib/create-directories! result-dir)
                 (log/info (format "Create a report %s with %s in %s" name payload workdir))
                 (spit log-path (json/write-str {:status "Running"
                                                 :msg ""}))
                 (update-process! task-id 0)
                 (publish-event! "quartet_metqc_report"
                                 {:data-file data-file
                                  :metadata-file metadata-file
                                  :dest-dir workdir
                                  :task-id task-id
                                  :metadata {:name name
                                             :description description
                                             :plugin-name "quartet-metqc-report"
                                             :plutin-type "ReportPlugin"
                                             :plugin-version (:plugin-version plugin-context)}})
                 response))
    :plugin-type :ReportPlugin
    :response-type :data2report}))

(defn update-log-process!
  "Update message into log file and process into database."
  [log-path coll task-id process]
  (spit log-path (json/write-str coll))
  (update-process! task-id process))

(defn date
  []
  (.format (java.text.SimpleDateFormat. "yyyy-MM-dd")
           (new java.util.Date)))

(defn- make-report!
  [{:keys [data-file metadata-file dest-dir metadata task-id]}]
  (let [log-path (fs-lib/join-paths dest-dir "log")
        result-dir (fs-lib/join-paths dest-dir "results")
        parameters-file (fs-lib/join-paths result-dir "general_information.json")
        results (ff/chain-fn-coll [(fn []
                                     (update-process! task-id 20)
                                     (metqc/call-metqc! data-file metadata-file result-dir))
                                   (fn []
                                     (update-process! task-id 50)
                                     (spit parameters-file (json/write-str {"Report Name" (:name metadata)
                                                                            "Description" (:description metadata)
                                                                            "Report Tool" (format "%s-%s"
                                                                                                  (:plugin-name metadata)
                                                                                                  (:plugin-version metadata))
                                                                            "Team" "Quartet Team"
                                                                            "Date" (date)}))
                                     {:status "Success" :msg ""})
                                   (fn []
                                     (update-process! task-id 80)
                                     (mq/multiqc result-dir dest-dir
                                                 {:template "quartet_metabolite_report"
                                                  :title "Quartet Report for Metabolomics"
                                                  :env {:PATH (add-env-to-path "quartet-metqc-report")}}))]
                                  (fn [result] (= (:status result) "Success")))
        status (:status (last results))
        msg (apply str (map :msg results))
        process (if (= status "Success") 100 -1)]
    (log/info (format "Running batch command: %s" (pr-str results)))
    (update-log-process! log-path {:status status
                                   :msg msg}
                         task-id process)))

;;; --------------------------------------------------- Lifecycle ----------------------------------------------------

(def events-init
  "Automatically called during startup; start event listener for quartet_metqc_report events."
  (make-events-init "quartet_metqc_report" make-report!))
