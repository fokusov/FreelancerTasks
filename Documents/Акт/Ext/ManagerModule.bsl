﻿
Процедура Печать(ТабДок, Ссылка) Экспорт
	//{{_КОНСТРУКТОР_ПЕЧАТИ(Печать)
	Макет = Документы.Акт.ПолучитьМакет("Печать");
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Акт.Дата КАК Дата,
	|	Акт.Номер КАК Номер,
	|	Акт.Ответственный КАК Ответственный,
	|	Акт.Сумма КАК Сумма,
	|	Акт.Задачи.(
	|		НомерСтроки КАК НомерСтроки,
	|		Задача.НаименованиеЗадачи КАК Задача,
	|		Задача.Заказчик КАК Заказчик,
	|		Сумма КАК Сумма
	|	) КАК Задачи
	|ИЗ
	|	Документ.Акт КАК Акт
	|ГДЕ
	|	Акт.Ссылка В(&Ссылка)";
	Запрос.Параметры.Вставить("Ссылка", Ссылка);
	Выборка = Запрос.Выполнить().Выбрать();

	ОбластьЗаголовок = Макет.ПолучитьОбласть("Заголовок");
	Шапка = Макет.ПолучитьОбласть("Шапка");
	ОбластьЗадачиШапка = Макет.ПолучитьОбласть("ЗадачиШапка");
	ОбластьЗадачи = Макет.ПолучитьОбласть("Задачи");
	Подвал = Макет.ПолучитьОбласть("Подвал");

	ТабДок.Очистить();

	ВставлятьРазделительСтраниц = Ложь;
	Пока Выборка.Следующий() Цикл
		Если ВставлятьРазделительСтраниц Тогда
			ТабДок.ВывестиГоризонтальныйРазделительСтраниц();
		КонецЕсли;

		ТабДок.Вывести(ОбластьЗаголовок);

		Шапка.Параметры.Заполнить(Выборка);
		ТабДок.Вывести(Шапка, Выборка.Уровень());

		ТабДок.Вывести(ОбластьЗадачиШапка);
		ВыборкаЗадачи = Выборка.Задачи.Выбрать();
		Пока ВыборкаЗадачи.Следующий() Цикл
			ОбластьЗадачи.Параметры.Заполнить(ВыборкаЗадачи);
			ТабДок.Вывести(ОбластьЗадачи, ВыборкаЗадачи.Уровень());
		КонецЦикла;

		Подвал.Параметры.Заполнить(Выборка);
		ТабДок.Вывести(Подвал);

		ВставлятьРазделительСтраниц = Истина;
	КонецЦикла;
	//}}
КонецПроцедуры
