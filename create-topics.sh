#!/bin/bash
# =============================================================================
# Crea los topics de Kafka con particiones explícitas.
# Ejecutar después de que Kafka esté healthy:
#   docker exec kafka /opt/kafka/bin/kafka-topics.sh --version
#   bash create-topics.sh
# =============================================================================

BOOTSTRAP="localhost:9092"
KAFKA_BIN="/opt/kafka/bin/kafka-topics.sh"

create_topic() {
  local topic=$1
  local partitions=$2
  local retention_ms=${3:-2592000000}  # 30 días default

  docker exec kafka $KAFKA_BIN \
    --bootstrap-server $BOOTSTRAP \
    --create \
    --if-not-exists \
    --topic "$topic" \
    --partitions "$partitions" \
    --replication-factor 1 \
    --config retention.ms="$retention_ms" \
    2>/dev/null

  echo "Topic '$topic' (partitions=$partitions, retention=${retention_ms}ms)"
}

echo "Creando topics de Kafka..."

# Topics principales (3 particiones para paralelismo por negocio)
create_topic "erp.orders"        3
create_topic "erp.inventory"     3
create_topic "erp.notifications" 3
create_topic "erp.sales"         3
create_topic "erp.day-close"     1

# Topics del marketplace-erp (1 partición)
create_topic "marketplace.stats" 1

# Topics de infraestructura (1 partición)
create_topic "erp.replies"       1
create_topic "erp.commands"      1

# Dead letter queue (retención 90 días = 7776000000ms)
create_topic "erp.dlq"           1  7776000000

echo "Topics creados correctamente."
