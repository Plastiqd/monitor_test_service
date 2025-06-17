#!/bin/bash

# Настройки
PROCESS_NAME="test"
MONITORING_URL="https://test.com/monitoring/test/api"
LOG_FILE="/var/log/monitoring.log"
TIMEOUT=10

# Проверяем, запущен ли процесс
is_process_running() {
    pgrep -x "$PROCESS_NAME" >/dev/null
}

 # Выполняем HTTPS-запрос к API
send_monitoring_request() {
    local response
    response=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$TIMEOUT" "$MONITORING_URL" 2>/dev/null)
    
    if [[ "$response" -ge 200 && "$response" -lt 300 ]]; then
        return 0
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Monitoring server unavailable (HTTP code: ${response:-"Connection failed"})" >> "$LOG_FILE"
        return 1
    fi
}

# Основная логика
main() {
    if is_process_running; then
        # Проверяем, был ли процесс перезапущен (сравнивая текущий PID с предыдущим)
        local current_pid=$(pgrep -x "$PROCESS_NAME")
        if [[ -f "/tmp/${PROCESS_NAME}_pid" ]]; then
            local previous_pid=$(cat "/tmp/${PROCESS_NAME}_pid")
            if [[ "$current_pid" != "$previous_pid" ]]; then
                echo "$(date '+%Y-%m-%d %H:%M:%S') - Process $PROCESS_NAME restarted (old PID: $previous_pid, new PID: $current_pid)" >> "$LOG_FILE"
            fi
        fi
        # Сохраняем текущий PID для следующего сравнения
        echo "$current_pid" > "/tmp/${PROCESS_NAME}_pid"

        if ! send_monitoring_request; then
            return 1
        fi
    fi
}

main
