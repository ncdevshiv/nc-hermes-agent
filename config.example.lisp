;; Configuration for Hermes Agent
;; An S-expression (alist) of settings
((:agent-name . "Hermes")
 (:version . "0.1.0")
 (:max-threads . 4)
 (:api-endpoint . "http://localhost:8080/api")
 (:log-level . :info)
 (:mcp-servers . (((:name . "sqlite")
                   (:command . "npx @modelcontextprotocol/server-sqlite --db hermes.db")))))
