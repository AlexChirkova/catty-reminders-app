#!/bin/bash
set -e

TARGET_DIR="/home/kali/catty-reminders-app"

BRANCH=${1:-lab1}
COMMIT_SHA=$2

echo "Переходим в директорию $TARGET_DIR..."
cd "$TARGET_DIR"

echo "Стягиваем последние изменения..."
git fetch origin "$BRANCH"
git checkout "$BRANCH"
git reset --hard "origin/$BRANCH"

echo "Записываем хэш коммита в .env..."
if [ -z "$COMMIT_SHA" ] || [ "$COMMIT_SHA" == "unknown" ]; then
    COMMIT_SHA=$(git rev-parse HEAD)
fi
echo "DEPLOY_REF=$COMMIT_SHA" > "$TARGET_DIR/.env"

echo "Обновляем зависимости..."
source .venv/bin/activate
pip install -r requirements.txt

echo "Устанавливаем браузеры Playwright..."
playwright install

echo "Запускаем тесты перед деплоем..."
if ./test.sh; then
    echo "Тесты успешно пройдены."
else
    echo "Ошибка в тестах! Деплой отменён."
    exit 1
fi

echo "Перезапускаем сервис приложения..."
sudo systemctl restart catty-app

echo "Развертывание завершено успешно!"
