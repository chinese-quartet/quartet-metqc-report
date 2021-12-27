(ns quartet-metqc-report.task
  (:require [quartet-metqc-report.metqc :as metqc]
            [local-fs.core :as fs-lib]
            [tservice-core.plugins.env :refer [add-env-to-path create-task! update-task!]]
            [tservice-core.plugins.util :as util]
            [clojure.data.json :as json]
            [clojure.tools.logging :as log]
            [tservice-core.tasks.async :refer [publish-event! make-events-init]]))

(defn date
  []
  (.format (java.text.SimpleDateFormat. "yyyy-MM-dd")
           (new java.util.Date)))

(defn update-process!
  [^String task-id ^Integer percentage]
  (let [record (cond
                 (= percentage 100) {:status "Finished"
                                     :percentage 100
                                     :finished_time (util/time->int (util/now))}
                 (= percentage -1) {:status "Failed"
                                    :finished_time (util/time->int (util/now))}
                 :else {:percentage percentage})
        record (merge {:id task-id} record)]
    (update-task! record)))

(defn update-log-process!
  "Update message into log file and process into database."
  [log-path coll task-id process]
  (spit log-path (json/write-str coll))
  (update-process! task-id process))

(defn post-handler
  [{{:keys [name data_file metadata_file description owner plugin-context]
     :or {description (format "Quality control report for %s" name)}
     :as payload} :body}]
  (log/info (format "Create a report %s with %s" name payload))
  (let [payload (merge {:description description} payload)
        data-file (metqc/correct-filepath data_file)
        metadata-file (metqc/correct-filepath metadata_file)
        workdir (fs-lib/dirname data-file)
        log-path (fs-lib/join-paths workdir "log")
        response {:report (format "%s/multiqc_report.html" workdir)
                  :log log-path}
        task-id (create-task! {:name           name
                               :description    description
                               :payload        payload
                               :owner          owner
                               :plugin-name    "quartet-metqc-report"
                               :plugin-type    "ReportPlugin"
                               :plugin-version (:plugin-version plugin-context)
                               :response       response})]
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

(defn make-report!
  [{:keys [data-file metadata-file dest-dir metadata task-id]}]
  (fs-lib/create-directories! (fs-lib/join-paths dest-dir "results"))
  (let [log-path (fs-lib/join-paths dest-dir "log")
        result-dir (fs-lib/join-paths dest-dir "results")
        parameters-file (fs-lib/join-paths result-dir "general_information.json")
        results (util/chain-fn-coll [(fn []
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
                                       (metqc/multiqc result-dir dest-dir
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

(def events-init
  "Automatically called during startup; start event listener for quartet_metqc_report events."
  (make-events-init "quartet_metqc_report" make-report!))
