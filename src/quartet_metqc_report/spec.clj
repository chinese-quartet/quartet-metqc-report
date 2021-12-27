(ns quartet-metqc-report.spec
  (:require [clojure.spec.alpha :as s]
            [spec-tools.core :as st]))

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
