ui = true

# Dev режим - хранит данные в памяти
# Для production нужно использовать storage "file" или другой бэкенд

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = true
}

api_addr = "http://0.0.0.0:8200"
cluster_addr = "http://0.0.0.0:8201"