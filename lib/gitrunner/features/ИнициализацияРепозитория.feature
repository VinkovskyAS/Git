# language: ru

Функциональность: Инициализация репозитория

Как разработчик
Я хочу иметь возможность инициализировать репозиторий git
Чтобы мочь автоматизировать больше рутинных действий на OneScript

Контекст:
    Допустим Я создаю новый объект ГитРепозиторий

Сценарий: Инициализация репозитория
    Допустим Я создаю временный каталог и сохраняю его в контекст
    Когда Я инициализирую репозиторий во временном каталоге
    Тогда Во временном каталоге существует репозиторий git 