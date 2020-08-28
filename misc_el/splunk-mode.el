;;; Package --- summary
;;; Derived mode for splunk queries
;;; Commentary:
;;; Derived mode for splunk queries

;;; Code:

(defvar splunk-openers
  '("sourcetype" "index" "source" "as"))
(defvar splunk-constants
  '("avg" "count" "distinct_count" "dc" "estdc" "estdc_error" "max" "mean" "median" "min" "mode" "percentile" "range" "stdev" "stdevp" "sum" "sumsq" "var" "varp" "first" "last" "list" "values" "earliest" "earliest_time" "latest" "latest_time" "per_day" "per_hour" "per_minute" "per_second" "rate" "case" "cidrmatch" "coalesce" "false" "if" "in" "like" "match" "null" "nullif" "searchmatch" "true" "validate" "printf" "tonumber" "tostring" "md5" "sha1" "sha256" "sha512" "now" "relative_time" "strftime" "strptime" "time" "isbool" "isint" "isnotnull" "isnull" "isnum" "isstr" "typeof" "abs" "ceiling" "ceil" "exact" "exp" "floor" "ln" "log" "pi" "pow" "round" "sigfig" "sqrt" "commands" "mvappend" "mvcount" "mvdedup" "mvfilter" "mvfind" "mvindex" "mvjoin" "mvrange" "mvsort" "mvzip" "split" "random" "len" "lower" "ltrim" "replace" "rtrim" "spath" "substr" "trim" "upper" "urldecode" "acos" "acosh" "asin" "asinh" "atan" "atan2" "atanh" "cos" "cosh" "hypot" "sin" "sinh" "tan" "tanh"))

(defvar splunk-booleans
    '("AND" "OR"))

(defvar splunk-keywords
    '("abstract" "accum" "addcoltotals" "addinfo" "addtotals" "analyzefields" "anomalies" "anomalousvalue" "anomalydetection" "append" "appendcols" "appendpipe" "arules" "associate" "audit" "autoregress" "bin" "bucketdir" "chart" "cluster" "cofilter" "collect" "concurrency" "contingency" "convert" "correlate" "datamodel" "dbinspect" "dedup" "delete" "delta" "diff" "erex" "eval" "eventcount" "eventstats" "extract" "fieldformat" "fields" "fieldsummary" "filldown" "fillnull" "findtypes" "folderize" "foreach" "format" "from" "gauge" "gentimes" "geom" "geomfilter" "geostats" "head" "highlight" "history" "iconify" "input" "inputcsv" "inputlookup" "iplocation" "join" "kmeans" "kvform" "loadjob" "localize" "localop" "lookup" "makecontinuous" "makemv" "makeresults" "map" "mcollect" "metadata" "metasearch" "meventcollect" "mstats" "multikv" "multisearch" "mvcombine" "mvexpand" "nomv" "outlier" "outputcsv" "outputlookup" "outputtext" "overlap" "pivot" "predict" "rangemap" "rare" "regex" "relevancy" "reltime" "rename" "replace" "rest" "return" "reverse" "rex" "rtorder" "savedsearch" "script" "scrub" "search" "searchtxn" "selfjoin" "sendemail" "set" "setfields" "sichart" "sirare" "sistats" "sitimechart" "sitop" "sort" "spath" "stats" "strcat" "streamstats" "table" "tags" "tail" "timechart" "timewrap" "top" "transaction" "transpose" "trendline" "tscollect" "tstats" "typeahead" "typelearner" "typer" "union" "uniq" "untable" "where" "x11" "xmlkv" "xmlunescape" "xpath" "xyseries"))

(defvar splunk-tab-width 4 "Width of a tab for splunk mode.")

  ;; Extra set of parens () around the list
  ;; as wanted by font-lock-defaults wants
  ;; Use  (quote) at the outermost level not ` (backquote)
(defvar splunk-font-lock-defaults
  `((
   ;; stuff between double quotes
   ("\"\\.\\*\\?" . font-lock-string-face)
   ;; ; : , ; { } =>  @ $ = are all special elements
   ("<=\\|>=\\|:\\|,\\|;\\|{\\|}\\|=>\\|@\\|$\\|=\\|!=" . font-lock-keyword-face)
   ("|" . font-lock-negation-char-face)
   ( ,(regexp-opt splunk-keywords 'words) . font-lock-constant-face)
   ( ,(regexp-opt splunk-constants 'words) . font-lock-keyword-face)
   ( ,(regexp-opt splunk-booleans 'words) . font-lock-warning-face)
   ( ,(regexp-opt splunk-openers 'words) . font-lock-function-name-face)
)))

(define-derived-mode splunk-mode prog-mode "Splunk mode"
  (setq font-lock-defaults splunk-font-lock-defaults)

    (when splunk-tab-width
        (setq tab-width splunk-tab-width))

    (setq comment-start "?\N{GRAVE ACCENT}comment(\"")
    (setq comment-end "\")?\N{GRAVE ACCENT}")

   (modify-syntax-entry ?\N{GRAVE ACCENT} "<" splunk-mode-syntax-table)
   (modify-syntax-entry ?\n ">" splunk-mode-syntax-table)
    (modify-syntax-entry ?_ "w" splunk-mode-syntax-table)

    )

(provide 'splunk-mode)
;;; splunk-mode.el ends here

