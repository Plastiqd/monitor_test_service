# Monitor Test Service

## Описание
Bash-скрипт для мониторинга процесса `test` в Linux. Основные функции:
- Проверка состояния процесса каждую минуту
- Отправка HTTPS-запросов на сервер мониторинга
- Логирование перезапусков процесса и ошибок соединения
- Интеграция с systemd для автоматического управления

## Требования
- ОС Linux с systemd
- Утилиты: `curl`, `pgrep`

## Установка

1. Установите скрипт мониторинга:
```bash
sudo install -m 755 monitor_test.sh /usr/local/bin/
```

2. Разместите конфигурационные файлы systemd:
```bash
sudo install -m 644 monitor-test.service /etc/systemd/system/
sudo install -m 644 monitor-test.timer /etc/systemd/system/
```

3. Активируйте сервис:
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now monitor-test.timer
```
## Проверка работы

1. Статус таймера:
```bash
systemctl status monitor-test.timer
```

2. Просмотр логов:
```bash
journalctl -u monitor-test.service -f
```

3. Ручной запуск:
```bash
sudo systemctl start monitor-test.service
```
