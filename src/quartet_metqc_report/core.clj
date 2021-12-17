(ns quartet-metqc-report.core
  (:require [tservice-core.tasks.http :as http-task]
            [quartet-metqc-report.spec :as spec]
            [quartet-metqc-report.task :as task]))

(def metadata
  (http-task/make-routes "quartet-metqc-report" :ReportPlugin
                         {:method-type :post
                          :endpoint "quartet-metqc-report"
                          :summary "Generate the QC Report for Quartet Metabolomics data."
                          :body-schema spec/quartet-metqc-report-params-body
                          :response-schema any?
                          :handler task/post-handler}))

(def events-init task/events-init)
