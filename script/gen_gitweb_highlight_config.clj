(ns gen-gitweb-highlight-config
  "GitWeb's is very conservative in what it uses from highlight.

   This little Clojure script takes a highlight's filetypes.conf and spits out
   the highlight config for gitweb.

   Installation locations vary, but I found filtetypes.conf under:
   /usr/local/etc/highlight/filetypes.conf

   highlight config for extensions and filenames is generated. I did not see
   a way to specify highlight's 'SheBang' items in GitWeb config.

   I decided to parse the filetypes.conf file with the instaparse library,
   which is pretty darn awesome! Expert instaparsers will hopefully forgive
   a beginner's implementation."
  (:require
   [instaparse.core :as insta]
   [clojure.java.io :as io]
   [clojure.string :as string]))

(def highlight-filetypes-conf-parser
  (insta/parser
    "<body> = <comment*> def
     <comment> = <comment-prefix> #'.*\\n*'
     <comment-prefix> = '--'
     def = <space*> var <space*> <assignment> <space*> value <space*>
     var = #'[a-zA-Z]+'
     (* We'll cheat and treat comma as whitespace *)
     <space> = #'[\\s,]+'
     <assignment> = '='
     <value> = string | list | matcher
     string = <space*> <string-delim> #'[^\"]*' <string-delim>
     matcher = #'\\[\\[\\^.*\\]\\]'
     <string-delim> = #'\"'
     list = <space*> <list-start> (list | def | value)* <space*> <list-end> <space*>
     list-start = '{'
     list-end = '}'"))

(defn tweak-parsed
  "Transform parsed file into something easier to work with"
  [instaparsed]
  (->> instaparsed
       (insta/transform {:var (comp keyword string/lower-case)
                         :def (fn [var value] {var value})
                         :list vector
                         :string identity
                         :matcher identity})
       first
       :filemapping
       (map (fn [hl-def] (if (every? map? hl-def)
                           (apply merge hl-def)
                           hl-def)))))

(defn gen-gitweb-conf [hl-conf conf-type-key gitweb-conf-var-name]
  (reduce (fn [s flat-conf-def]
            (str s
                 "$" gitweb-conf-var-name "{'" (:conf-val flat-conf-def) "'} = '" (:lang flat-conf-def)  "';\n"))
          (str "our %" gitweb-conf-var-name ";\n")
          (for [hl-conf-def (sort-by :lang hl-conf)
                conf-val (conf-type-key hl-conf-def)
                :let [lang (:lang hl-conf-def)]]
            {:lang lang :conf-val conf-val})))

(defn gitweb-highlight-conf
  "Convert to gitweb_config.perl format"
  [hl-conf]
  (str "# The highlight following config was programmatically transcribed from highlight's filetypes.conf\n"
       "\n"
       (gen-gitweb-conf hl-conf :extensions "highlight_ext")
       "\n"
       (gen-gitweb-conf hl-conf :filenames "highlight_basename")))

(defn -main [& args]
  (when (or (not= 2 (count args)))
    (println "Usage: gen-gitweb-higlight-config <highlight filetypes.conf filename> <output filename>")
    (System/exit 1))

  (let [in-filename (first args)
        out-filename (second args)]
    (when (not (.exists (io/file in-filename)))
      (println "specified highlight filetypes.conf file not found:" in-filename)
      (System/exit 1))

    (println "Converting highlight filetypes config to GitWeb perl syntax")
    (println "Source:" in-filename)
    (println "Dest:  " out-filename)
    (let [hl-conf (->> (slurp in-filename)
                       highlight-filetypes-conf-parser
                       tweak-parsed)]
      (spit out-filename (gitweb-highlight-conf hl-conf))
      (println "Highlight conversion complete."))))
