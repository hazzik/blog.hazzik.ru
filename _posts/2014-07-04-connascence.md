---
layout: post
title: "Connascence"
date: 2014-07-04T13:55:24+12:00
tags:
- Connascence
- Разработка
- Best Practicies
- Principles
- Software Design Metrics
---
Для меня это очень странно, но данный термин или практика не получили широкого распространения в рускоязычном мире разработки ПО, и, видимо, по-этому данный термин даже не имеет перевода. [Подсмотрим](http://www.thefreedictionary.com/Connascence) в The Free Dictionary что же это слово означает:

    Con`nas´cence, существительное

    1.	Одновременное рождение двух или более; одновременное производство двух и более вместе.
    2.	То, что было рождено или произведено вместе с другим.
    3.	Акт совместного взросления.

Я позволю себе перевести термин __Connascence__ как "близнецовая связь" (может быть есть более подходящий перевод?). Итак, далее будет приблизительный перевод [статьи](https://en.wikipedia.org/wiki/Connascence_(computer_programming)) из англоязычной Википедии.

В разработке программного обеспечения два компонента обладают близнецовой связью (__Connascence__), если изменение в одном компоненте будут требовать изменение других компонентов для поддержания общей корректности всей системы.

Connascence – это метрика качества программного обеспечения разарботанная Меилиром Пейдж-Джонсом (Meilir Page-Jones) чтобы разрешить рассуждения о сложности, вызванные отношениями зависимости в объектно-ориентированном дизайне, подобно тому, как это делает связанность (coupling) в структурном дизайне. В дополнение, к возможности категоризировать отношения, "близнецовая связь" также предоставляет систему для сравнения различных типов зависимостей. Такое сравнение часто подсказывает пути улучшения качества программного обеспечения.

Метрики
=======

## Сила

Форма "близнецовой связи" считается более сильной, если требует больших компенсационных изменений в связанных элементах. Чем сильнее связь, тем сложнее и затратнее совершить изменения в связанных компонентах.

## Степень

Приемлемость связи связана со степенью ее возникновения. Связь, обладающая низкой степенью, может быть приемлемой, но связь, обладающая высокой степенью, не должна быть приемлема. Например, функция или метод, который принимает два аргумента обычно считаются приемлемымы. Однако это обычно неприемлемо для функций или методов принимать десять аргументов. Элементы с высокой степенью "близнецовой связи" требуют боллее сложных и затратных изменений, чем элементы, которые имеют более низкий уровень связи.

## Локальность

Локальность имеет значение при анализе "близнецовой связи". Сильные формы "близнецовой связи" приемлемы, если связанные элементы  расположены достаточно близко. Например, некоторые языки используют позиционные аргументы для вызова функций или методов. Эта "близнецовая связть по месту" приемлема из-за близкого расположения вызвающего и вызываемого кода, но вызов веб сервиса с использованием позицонных аргументов неприемлео, из-за достаточной отдаленности и несвязанности компонентов. "Близнецовые связи" с теми же силой и степенью будут иметь большую сложность и стоимость изменений, чем дальше связанные компоненты расположены.

Типы "близнецовых связей"
=========================

Далее представлен список близнецовых связей , остортированный приблизительно, от слабых до сильных.

## Близнецовая связь по имени (Connascence of Name – CoN)

Близнецовая связь по имени возникает, когда несколько компонентов должны согласовать имя сущности. Например, такой связью является имя метода: если имя метода изменяется, то вызывающий код должен быть изменен, так, чтобы использовать новое имя метода.

## Близнецовая связь по типу (Connascence of Type – CoT)

Близнецовая связь по типу возникает, когда несколько компонентов должны согласовать тип сущности. В статически типизированных языках программирования, тип аргументов метода может являтся образцом такой связи. Например, если метод изменит тип принимаемого аргумента с целого (integer) на строку (string), то вызывающий код должен быть изменен, так, чтобы отразить эти изменения.

## Близнецовая связь по смыслу (Connascence of Meaning – CoM)

Близнецовая связь по смыслу возникает, когда несколько компонентов должны согласовать смысл каких-то значений. Например, возврашение из метода 0 и 1 для обозначения true и false соответсвенно.

## Близнецовая связь по месту (Connascence of Position – CoP)

Близнецовая связь по месту (по позиции, по расположению) возникает, когда несколько компонентов должны согласовать порядок значений. Примером близнецовой связи по месту могут служить позиционные аргументы в методе. Вызвающий и вызываемый код должны согласиться с семантикой первого, воторого и т.д. параметров.

## Близнецовая связь по алгоритму (Connascence of Algorithm – CoA)

Близнецовая связь по алгоритму возникает, когда несколько компонентов должны использовать определенный алгоритм.   


## Близнецовая связь по исполнению (Connascence of Execution – CoE)

Близнецовая связь по исполнению возникает, когда важен порядок вызова компоентов.

## Близнецовая связь по времени (Connascence of Timing – CoT)

Близнецовая связь по исполнению возникает, когда важено время выполнения каждого из компоентов.

## Близнецовая связь по значениям (Connascence of Values – CoV)

Близнецовая связь по значениям возникает, когда несколько значений должны изменяться одновременно.

## Близнецовая связь по идентификатору (Connascence of Identity – CoI)

Близнецовая связь по идентификатору возникает, когда несколько компонетов должны ссылаться на какую-то сущность.

Уменьшение "близнецовой связи"
==============================
Уменьшение "близнецовой связи" будет уменьшать стоимость изменения программной системы. Один из путей уменьшения "близнецовой связи" - это замена более сильных связей более слабыми. Другой путь - это уменьшение степени и увеличение локальности связанных элементов.
