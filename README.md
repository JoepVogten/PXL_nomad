# Prometheus
Hieronder staat mijn nomad job voor het opzetten van prometheus binnen mijn cluster. prometheus wordt gepulled met docker en wordt geopend op poort :9090. prometheus heeft een prometheus.yml file nodig met de targets in de gescraped moeten worden. Ik doe dit met behulp van EOH. Ik geef mee dat hij alert-manager, nomad, cadvisor en nog andere services moet zoeken in consul (dynamic). Node-exporter staat er ook in maar dit is static gedefinieerd.

```
job "prometheus" {
  datacenters = ["dc1"]
  type        = "service"

  group "monitoring" {
    count = 1

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    ephemeral_disk {
      size = 300
    }

    task "prometheus" {
      template {
        change_mode = "noop"
        destination = "local/cadvisor_alert.yml"
        data = <<EOH
---
groups:
- name: prometheus_alerts
  rules:
  - alert: cadvisor down
    expr: absent(up{job="cadvisor"})
    for: 10s
    labels:
      severity: critical
    annotations:
      description: "Our cadvisor is down."
EOH
      }

      template {
        change_mode = "noop"
        destination = "local/prometheus.yml"

        data = <<EOH
---
global:
  scrape_interval:     5s
  evaluation_interval: 5s
alerting:
  alertmanagers:
  - consul_sd_configs:
    - server: '{{ env "NOMAD_IP_prometheus_ui" }}:8500'
      services: ['alertmanager']
rule_files:
  - "cadvisor_alert.yml"
scrape_configs:
  - job_name: 'alertmanager'
    consul_sd_configs:
    - server: '{{ env "NOMAD_IP_prometheus_ui" }}:8500'
      services: ['alertmanager']
  - job_name: 'nomad_metrics'
    consul_sd_configs:
    - server: '{{ env "NOMAD_IP_prometheus_ui" }}:8500'
      services: ['nomad-client', 'nomad']
    relabel_configs:
    - source_labels: ['__meta_consul_tags']
      regex: '(.*)http(.*)'
      action: keep
    scrape_interval: 5s
    metrics_path: /v1/metrics
    params:
      format: ['prometheus']
  - job_name: 'node_exporter'
    static_configs:
    - targets: ['10.0.0.10:9100']
  
  - job_name: 'cadvisor'
    consul_sd_configs:
    - server: '{{ env "NOMAD_IP_prometheus_ui" }}:8500'
      services: ['cadvisor']
EOH
      }

      driver = "docker"

      config {
        image = "prom/prometheus:latest"

        volumes = [
          "local/prometheus.yml:/etc/prometheus/prometheus.yml",
        ]

        port_map {
          prometheus_ui = 9090
        }
      }

      resources {
        network {
             port "prometheus_ui" {
             to = 9090
             static = 9090
             }

        }
      }
      service {
        name = "prometheus"
        tags = ["urlprefix-/"]
        port = "prometheus_ui"

        check {
          name     = "prometheus_ui port alive"
          type     = "http"
          path     = "/-/healthy"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
```

# software rollen
## grafana
### handlers
We geven hier aan dat dit gerunt gaat worden als een nomad job. Ik geef aan waar de nomad gevonden kan worden en welke job we daarin gaan zetten.

```---
- name: start grafana job
  shell: nomad job run -address=http://10.0.0.10:4646/ /opt/nomad/grafana.nomad || exit 0
```
### tasks
Hier geef ik de task op voor de nomad job voor grafana. Ik geef de src mee naar de handler die ik hieronder bespreek. Met de notify geef ik aan dat de job gestart moet worden.
```---
- name: nomad job grafana
  template:
    src: grafana.nomad.sh.j2
    dest: /opt/nomad/grafana.nomad
  notify: start grafana job
```
### handlers
Dit is de template en tevens ook de job voor grafana. Elke job is eigenlijk ongeveer hetzelfde buiten de poortnummers. Grafana staat bijvoorbeeld op poort 3000.

```job "grafana" {
    datacenters = ["dc1"]
    type        = "service"

    group "grafana" {

        task "grafana"{
            driver = "docker"
        
            config {
                image = "grafana/grafana"
                        force_pull = true
                        port_map   = {
                            grafana_web = 3000
                        }
                        logging {
                            type = "journald"
                            config {
                                tag = "GRAFANA"
                            }
                        }
            }

            service {
                name = "grafana"
                port = "grafana_web"
            }
            
            resources {
                network {
                    port "grafana_web" {
                        static = "3000"
                    }
                }
            }
        }
    }
}
```

Voor alle andere nieuwe roles heb ik ongeveer dezelfde setup gebruikt. Hieronder alle poortnummers.

```Grafana       :3000 
Alertmanager  : 9093
Cadvisor      : 8080
Prometheus    : 9090
Node-exporter : 9100
```

# Grafana dashboard
helaas kon ik hier niet verder aan werken door fout in mijn docker.

# Bronvermelding
- slides uit de lessen
- https://prometheus.io/docs/prometheus/latest/configuration/configuration/
- https://prometheus.io/docs/prometheus/latest/configuration/template_examples/
- https://github.com/google/cadvisor
- https://learn.hashicorp.com/tutorials/nomad/prometheus-metrics
