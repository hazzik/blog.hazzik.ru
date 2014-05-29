---
layout: post
title: MvcExtensions - решение проблемы DropDown Lists
date: '2012-04-02T07:30:00+12:00'
tags:
- MvcExtensions
- ASP.NET MVC
- DropDown
tumblr_url: http://blog.hazzik.ru/post/20302159000/mvcextensions-solving-drop-down-lists-problem
redirect_from:
- /post/20302159000/mvcextensions-solving-drop-down-lists-problem/
- /post/20302159000/
---
С самого выхода еще первой версии [ASP.NET MVC](http://www.asp.net/mvc) три года назад я столкнулся с проблемой выпадающих списков. Наверное [каждый](http://habrahabr.ru/post/106370/) [из вас](http://pashapash.com/2010/12/dropdown-v-asp-net-mvc-chast-1/) [задавал себе вопрос](http://www.google.ru/webhp#q=asp.net+mvc+dropdownlist): &#8220;Как корректно передавать данные для отображения в выпадающие списки?&#8221; Вот и меня до недавнего времени этот вопрос волновал и очень существенно. Я буквально не мог спать;)

<!-- more -->

Допустим у нас есть форма, для создания фильма. И нам нужно из DropDown выбрать жанр фильма. Откровенно &#8220;профанские&#8221; решения, такие как получение возможных значений прямо на View я рассматривать не буду.

## Решение &#8220;в лоб&#8221;

Программисты, сталкивающиеся с этой проблемой очень часто идут решать ее в лоб: в модели создается дополнительное свойство Genres типа SelectList и оно заполняется в методе контроллера.

Модель:

```csharp
public class Movie {
    public int GenreId { get; set; }
    public SelectList Genres { get; set; }    
    //...
} 
```

Контроллер:

```csharp
public class MoviesController {
    [HttpGet] public ActionResult Create() {
        var model = new Movie() { Genres = GetAllGenresFromDatabase(); }
        return View(model); 
    }

    [HttpPost] public ActionResult Create(Movie form) {
        // do something with movie.
    }

    [HttpGet] public ActionResult Edit(int id) {
        var model = GetMovieFromDatabase();
        model.Genres = GetAllGenresFromDatabase(); 
        return View(model); 
    }

    [HttpPost] public ActionResult Edit(EditMovie form) {
        // do something with movie.
    }
    //...
}
```

Но у этого решения для меня есть огромные недостатки:

1.  Лишнее поле в модели
2.  Необходимо создавать модель при отображении формы создания
3.  Дублирование кода заполнения возможных значений. <small>Эта проблема становится особенно актуальное, если у вас в системе можно во многих местах выбирать значения из одного и того же справочника.</small>
4.  Нет возможности использовать `Html.EditorForModel()` - ASP.NET отображает общую разметку для всех полей модели, при этом при отображении какого-либо поля модели нет доступа к другим полям.

## Решение с использованием ViewBag / ViewData

Это решение по большей части аналогично предыдущему решению, за тем лишь исключением, что возможные значение передаются через ViewBag:

Модель:

```csharp
public class Movie {
    [UIHint("Genres")]
    public int GenreId { get; set; }
    //...
}
```

Контроллер:

```csharp
public class MoviesController {
    [HttpGet] public ActionResult Create() {
        ViewBag.Genres = GetAllGenresFromDatabase();
        return View(); 
    }

    [HttpPost] public ActionResult Create(Movie form) {
        // do something with movie.
    }

    [HttpGet] public ActionResult Edit(int id) {
        var model = GetMovieFromDatabase();
        ViewBag.Genres = GetAllGenresFromDatabase(); 
        return View(model); 
    }

    [HttpPost] public ActionResult Edit(EditMovie form) {
        // do something with movie.
    }
    //...
}
```

Плюсы, по сравнению с предыдущим решением.

1.  Нет лишних полей в модели
2.  Нет необходимости создавать модель при отображении формы создания
3.  Можно использовать `Html.EditorForModel()` в связке с шаблоном (EditorTemplate). При этом для каждого справочника необходим свой шаблон

Минусы

1.  Используется dynamic или magic-strings*, что не всегда положительно сказывается на возможности рефакторинга
2.  Дублирование кода заполнения возможных значений
3.  Необходимо иметь по шаблону на каждый тип справочника

Недостатки

### Улучшенное решение с использованием ViewBag / ViewData

Для устранения дублировани кода получения возможных значений вынесем этот код в отдельный ActionFilter.

Модель:

та же, что в предыдущем примере


ActionFilter:

```csharp
public class PopulateGenresAttribute: ActionFilterAttribute {
    public override void OnActionExecuted(ActionExecutedContext filterContext) {
        filterContext.Controller.ViewData["Genres"] = GetAllGenresFromDatabase();
    }
    //...
}    
```

Контроллер:

```csharp
public class MoviesController {
    [HttpGet, PopulateGenres] public ActionResult Create() {
        return View(); 
    }

    [HttpPost] public ActionResult Create(Movie form) {
        // do something with movie.
    }

    [HttpGet, PopulateGenres] public ActionResult Edit(int id) {
        var model = GetMovieFromDatabase();
        return View(model); 
    }

    [HttpPost] public ActionResult Edit(EditMovie form) {
        // do something with movie.
    }
    //...
}
```

Плюсы, по сравнению с предыдущим решением.

1.  Устранено дублирование кода заполнения возможных значений

Минусы

1.  Используется dynamic или magic-strings*, что не всегда положительно сказывается на возможности рефакторинга
2.  Необходимо иметь по шаблону на каждый тип справочника

### Улучшенное решение с использованием ViewBag / ViewData + [MvcExtnsions](http://mvcextensions.codeplex.com)

В MvcExensions есть замечательные [методы для работы с drop-down list](http://github.com/MvcExtensions/Core/blob/master/src/MvcExtensions/ModelMetadata/HtmlSelectModelMetadataItemBuilderExtensions.cs): AsDropDownList / AsListBox (первый для выпадающего списка, второй для множественного выбора). Это методы-расширения для конструктора метаданных. Данные методы устанавливают шаблон и позволяют передать в шаблон название поля ViewBag, которое хранит данные с возможными значениями. Таким образом решается проблема с необходимостю иметь по шаблону на каждый справочник.

Модель:

```csharp
public class Movie {
    public int GenreId { get; set; }
} 
```

Метаданные:

```csharp
public class MovieMetadata : ModelMetadataConfiguration {
    public MovieMetadata {
        Configure(movie =&gt; movie.GenreId).AsDropDownList("Genres"/*шаблон*/);
    }
}
```

Контроллер:

как в предыдущем примере.


Плюсы, по сравнению с предыдущим решением:

1.  Используется два универсальных шаблона (DropDownList / ListBox) для всех списков (есть возможность указать свой шаблон, если это необходимо)

Минусы:

1.  Используется dynamic или magic-strings*, что не всегда положительно сказывается на возможности рефакторинга.

### Решение с использованием ChildAction

Если попытаться использовать child action &#8220;в лоб&#8221;, то это решение просто-напросто не будет работать: не будет работать клиенская валидация, не будут работать сценарии в случае сложных вложенных форм и т.д. В [статье](http://pashapash.com/2010/12/dropdown-v-asp-net-mvc-chast-1/) ([часть 2](http://pashapash.com/2011/01/dropdown-v-asp-net-mvc-chast-2/)) неизвестного автора (быстрый поиск выдал только [профиль](http://habrahabr.ru/users/PashaPash/) на хабре) решены эти проблемы, и по-этому я буду рассматривать _окончательное решение автора_.

Модель

```csharp
public class Movie {
    [UIHint("Genres")]
    public int GenreId { get; set; }
} 
```

Контроллеры:

```csharp
public class MoviesController {
    [HttpGet] public ActionResult Create() {
        return View(); 
    }

    [HttpPost] public ActionResult Create(Movie form) {
        // do something with movie.
    }

    [HttpGet] public ActionResult Edit(int id) {
        var model = GetMovieFromDatabase();
        return View(model); 
    }

    [HttpPost] public ActionResult Edit(EditMovie form) {
        // do something with movie.
    }
}

public class GenresController {
    public ActionResult List() {
        int? selectedGenreId = this.ControllerContext.ParentActionViewContext.ViewData.Model as int?;

        var genres = GetGenresFormDatabase();

        var model = new SelectList(genres, "Id", "DisplayName", selectedGenreId);

        this.ViewData.Model = model;
        this.ViewData.ModelMetadata = this.ControllerContext.ParentActionViewContext.ViewData.ModelMetadata;

        return View("DropDown");
    }
}
```

Плюсы, по сравнению, с решениями с ViewBag / ViewData

1.  Не используется dynamic или magic-strings
2.  Устранено дублирование кода заполнения возможных значений

Минусы

1.  Дублирование обслуживающего кода
2.  Необходимо иметь по шаблону на каждый тип справочника
3.  Не поддерживается сценарий Post-Redirect-Get

### Решение с использованием ChildAction + MvcExtensions

Я решил, усовершенствовать последнее решение и применить опыт использования ActionFilter, и теперь, с версии [2.5.0-rc8000 в MvcExtensions](http://nuget.org/packages/MvcExtensions) поддерживаются выпадающие списки &#8220;из коробки&#8221;. Были добавлены методы расширения, позволяющие указывать, что для отображения данного поля модели необходимо вызвать ChildAction. Также был добавлен `SelectListActionAttribute`, который занимается обслуживанием метода, предоставлюящего возможнные значения для выпадающего списка. Поддерживается Post-Redirect-Get

Модель:

```csharp
public class Movie {
    public int GenreId { get; set; }
}
```

Метаданные:

```csharp
public class MovieMetadata : ModelMetadataConfiguration {
    public MovieMetadata {
        Configure(movie =&gt; movie.GenreId).RenderAction("List", "Genres");
    }
}
```

Контроллеры:

```csharp
public class MoviesController {
    [HttpGet] public ActionResult Create() {
        return View(); 
    }

    [HttpPost] public ActionResult Create(Movie form) {
        // do something with movie.
    }

    [HttpGet] public ActionResult Edit(int id) {
        var model = GetMovieFromDatabase();
        return View(model); 
    }

    [HttpPost] public ActionResult Edit(EditMovie form) {
        // do something with movie.
    }
}

public class GenresController {
    [ChildActionOnly, SelectListAction] public ActionResult List(int selected) {
        var model = GetGenresFormDatabase(selected);
        return View("DropDown", model);
    }
}
```

Плюсы, по сравнению с предыдущими решениями

1.  Устранено дублирование обслужвающего кода
2.  Используется единый шаблон
3.  MultiSelect &#8220;из коробки&#8221;
4.  Поддерживается сценарий Post-Redirect-Get

# Вместо заключения.

Для меня, как одного из разработчиков MvcExtensions варианты с использованием этой библиотеки предпочтительнее.

Пример кода для варианта с ViewBag / ViewData + MvcExtensions здесь: [http://github.com/MvcExtensions/Core/tree/master/samples](http://github.com/MvcExtensions/Core/tree/master/samples)

Пример кода для варианта с ChildAction + MvcExtensions здесь: [http://github.com/hazzik/DropDowns](http://github.com/hazzik/DropDowns)

* * *

*magic-strings легко побеждаются, использованием констант, и по-этому для меня в данном контексте предпочтительней, чем dynamic

PS: Возможности MvcExtensions для расширения старого доброго ASP.NET MVC просто безграничны.
