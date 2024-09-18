; Этот блок реализует логику обмена информацией с графической оболочкой,
; а также механизм остановки и повторного пуска машины вывода
(deftemplate ioproxy			; шаблон факта-посредника для обмена информацией с GUI
	(slot fact-id)			; теоретически тут id факта для изменения
	(multislot answers)		; возможные ответы
	(multislot messages)		; исходящие сообщения
	(slot reaction)			; возможные ответы пользователя
	(slot value)			; выбор пользователя
	(slot restore)			; забыл зачем это поле
)

; Собственно экземпляр факта ioproxy
(deffacts proxy-fact
	(ioproxy
		(fact-id 0112)		; это поле пока что не задействовано
		(value none)		; значение пустое
		(messages)		; мультислот messages изначально пуст
		(answers)		; мультислот answers тоже
	)
)

(defrule append-answer-and-proceed
	(declare (salience 99))
	?current-answer <- (appendanswer ?new-ans)
	?proxy <- (ioproxy (answers $?ans-list))
	=>
	(printout t "Answer appended : " ?new-ans " ... proceed ... " crlf)
	(modify ?proxy (answers $?ans-list ?new-ans))
	(retract ?current-answer)
)

(defrule clear-messages
	(declare (salience 90))
	?clear-msg-flg <- (clearmessage)
	?proxy <- (ioproxy)
	=>
	(modify ?proxy (messages)(answers))
	(retract ?clear-msg-flg)
	(printout t "Messages cleared ..." crlf)
)

(defrule set-output-and-halt
	(declare (salience 98))
	?current-message <- (sendmessagehalt ?new-msg)
	?proxy <- (ioproxy (messages $?msg-list))
	=>
	(printout t "Message set : " ?new-msg " ... halting ... " crlf)
	(modify ?proxy (messages ?new-msg))
	(retract ?current-message)
	(halt)
)

(defrule append-output-and-halt
	(declare (salience 98))
	?current-message <- (appendmessagehalt $?new-msg)
	?proxy <- (ioproxy (messages $?msg-list))
	=>
	(printout t "Messages appended : " $?new-msg " ... halting ... " crlf)
	(modify ?proxy (messages $?msg-list $?new-msg))
	(retract ?current-message)
	(halt)
)

(defrule set-output-and-proceed
	(declare (salience 98))
	?current-message <- (sendmessage ?new-msg)
	?proxy <- (ioproxy)
	=>
	(printout t "Message set : " ?new-msg " ... proceed ... " crlf)
	(modify ?proxy (messages ?new-msg))
	(retract ?current-message)
)

(defrule append-output-and-proceed
	(declare (salience 98))
	?current-message <- (appendmessage ?new-msg)
	?proxy <- (ioproxy (messages $?msg-list))
	=>
	(printout t "Message appended : " ?new-msg " ... proceed ... " crlf)
	(modify ?proxy (messages $?msg-list ?new-msg))
	(retract ?current-message)
)

;___________________________________________________________________________

(deftemplate fact
	(slot num)
	(slot description)
	(slot certainty)
)

(deffacts start-fact
	(fact (num 6666)(description "Старт"))
)

(defrule welcome
	(declare (salience 100))
	?premise <- (fact (num 6666)(description "Старт"))
	=>
	(retract ?premise)
	(assert (fact (num 5000)(description "Про дополнения пока не спросили")))
	(assert (fact (num 5001)(description "Про температуру пока не спросили")))
	(assert (fact (num 5002)(description "Про погоду пока не спросили")))
	(assert (fact (num 5003)(description "Про время года пока не спросили")))
	(assert (fact (num 5004)(description "Про бюджет пока не спросили")))
	(assert (fact (num 5005)(description "Про локацию пока не спросили")))
	(assert (fact (num 5006)(description "Про транспорт пока не спросили")))
	(assert (appendmessagehalt "Здравствуйте, я Алиса"))
)

(defrule askforfeatures
	(declare (salience 19))
	?premise <- (fact (num 5000)(description "Про дополнения пока не спросили"))
	=>
	(retract ?premise)
	(assert (appendanswer "24-Есть виза-1000-Виза не имеет значения"))
	(assert (appendanswer "25-Отдых на море-999-Море не имеет значения"))
	(assert (appendanswer "26-Катание на лыжах-998-Лыжи не имеют значения"))
	(assert (appendanswer "27-Горная местность-997-Горы не имеют значения"))
	(assert (appendanswer "28-Поправить здоровье в санатории-996-Санаторий не имеет значения"))
	(assert (appendanswer "29-Известные исторические города-995-Исторические города не имеют значения"))
	(assert (appendanswer "30-Малолюдный курорт-994-Наполненность курорта не имеет значения"))
	(assert (appendmessagehalt "#ask_features"))
)


(defrule askfortemperature
	(declare (salience 20))
	?premise <- (fact (num 5001)(description ?desc))
	=>
	(retract ?premise)
	(assert (appendanswer "16-Ниже минус 10 градусов"))
	(assert (appendanswer "17-минус 10-0 градусов"))
	(assert (appendanswer "18-от 0 до 15 градусов"))
	(assert (appendanswer "19-от 15 до 25 градусов"))
	(assert (appendanswer "20-от 25 до 35 градусов"))
	(assert (appendanswer "21-от 35 градусов"))
	(assert (appendmessagehalt "#ask_temperature"))
)

(defrule askforweather
	(declare (salience 20))
	?premise <- (fact (num 5002)(description ?desc))
	=>
	(retract ?premise)
	(assert (appendanswer "1-Много осадков"))
	(assert (appendanswer "2-Среднее количество осадков"))
	(assert (appendanswer "3-Мало осадков"))
	(assert (appendanswer "4-Ветрено"))
	(assert (appendanswer "5-Умеренный ветер"))
	(assert (appendanswer "6-Высокая влажность"))
	(assert (appendanswer "7-Умеренная влажность"))
	(assert (appendanswer "8-Низкая влажность"))
	(assert (appendmessagehalt "#ask_weather"))
)

(defrule askforseason
	(declare (salience 20))
	?premise <- (fact (num 5003)(description ?desc))
	=>
	(retract ?premise)
	(assert (appendanswer "12-Лето"))
	(assert (appendanswer "13-Зима"))
	(assert (appendanswer "14-Весна"))
	(assert (appendanswer "15-Осень"))
	(assert (appendmessagehalt "#ask_season"))
)

(defrule askfortransport
	(declare (salience 20))
	?premise <- (fact (num 5004)(description ?desc))
	=>
	(retract ?premise)
	(assert (appendanswer "240-Самолетом"))
	(assert (appendanswer "250-Поездом"))
	(assert (appendanswer "260-На машине"))
	(assert (appendmessagehalt "#ask_transport"))
)

(defrule askforbudget
	(declare (salience 20))
	?premise <- (fact (num 5005)(description ?desc))
	=>
	(retract ?premise)
	(assert (appendanswer "9-Малый бюджет"))
	(assert (appendanswer "10-Средний бюджет"))
	(assert (appendanswer "11-Большой бюджет"))
	(assert (appendmessagehalt "#ask_budget"))
)

(defrule askforlocation
	(declare (salience 20))
	?premise <- (fact (num 5006)(description ?desc))
	=>
	(retract ?premise)
	(assert (appendanswer "22-Отдых по России"))
	(assert (appendanswer "23-Заграница"))
	(assert (appendmessagehalt "#ask_location"))
)

(defrule fail
	(declare (salience 10))
	=>
	(assert (appendmessagehalt "Применимые правила закончились("))
)

;_____________________________________________________________________________________
