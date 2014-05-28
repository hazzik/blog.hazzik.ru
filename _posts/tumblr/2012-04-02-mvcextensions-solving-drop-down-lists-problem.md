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
<p>С самого выхода еще первой версии <a href="http://www.asp.net/mvc">ASP.NET MVC</a> три года назад я столкнулся с проблемой выпадающих списков. Наверное <a href="http://habrahabr.ru/post/106370/">каждый</a> <a href="http://pashapash.com/2010/12/dropdown-v-asp-net-mvc-chast-1/">из вас</a> <a href="http://www.google.ru/webhp#q=asp.net+mvc+dropdownlist">задавал себе вопрос</a>: &#8220;Как корректно передавать данные для отображения в выпадающие списки?&#8221; Вот и меня до недавнего времени этот вопрос волновал и очень существенно. Я буквально не мог спать;)</p>

<!-- more -->

<p>Допустим у нас есть форма, для создания фильма. И нам нужно из DropDown выбрать жанр фильма. Откровенно &#8220;профанские&#8221; решения, такие как получение возможных значений прямо на View я рассматривать не буду.</p>

<h2>Решение &#8220;в лоб&#8221;</h2>

<p>Программисты, сталкивающиеся с этой проблемой очень часто идут решать ее в лоб: в модели создается дополнительное свойство Genres типа SelectList и оно заполняется в методе контроллера.</p>

<p>Модель:</p>

<pre><code>public class Movie {
    public int GenreId { get; set; }
    public SelectList Genres { get; set; }    
    //...
} 
</code></pre>

<p>Контроллер:</p>

<pre><code>public class MoviesController {
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
</code></pre>

<p>}</p>

<p>Но у этого решения для меня есть огромные недостатки:</p>

<ol><li>Лишнее поле в модели</li>
<li>Необходимо создавать модель при отображении формы создания</li>
<li>Дублирование кода заполнения возможных значений. <small>Эта проблема становится особенно актуальное, если у вас в системе можно во многих местах выбирать значения из одного и того же справочника.</small></li>
<li>Нет возможности использовать <code>Html.EditorForModel()</code> - ASP.NET отображает общую разметку для всех полей модели, при этом при отображении какого-либо поля модели нет доступа к другим полям.</li>
</ol><h2>Решение с использованием ViewBag / ViewData</h2>

<p>Это решение по большей части аналогично предыдущему решению, за тем лишь исключением, что возможные значение передаются через ViewBag:</p>

<p>Модель:</p>

<pre><code>public class Movie {
    [UIHint("Genres")]
    public int GenreId { get; set; }
    //...
}
</code></pre>

<p>Контроллер:</p>

<pre><code>public class MoviesController {
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
</code></pre>

<p>Плюсы, по сравнению с предыдущим решением.</p>

<ol><li>Нет лишних полей в модели</li>
<li>Нет необходимости создавать модель при отображении формы создания</li>
<li>Можно использовать <code>Html.EditorForModel()</code> в связке с шаблоном (EditorTemplate). При этом для каждого справочника необходим свой шаблон</li>
</ol><p>Минусы</p>

<ol><li>Используется dynamic или magic-strings*, что не всегда положительно сказывается на возможности рефакторинга</li>
<li>Дублирование кода заполнения возможных значений</li>
<li>Необходимо иметь по шаблону на каждый тип справочника</li>
</ol><p>Недостатки</p>

<h3>Улучшенное решение с использованием ViewBag / ViewData</h3>

<p>Для устранения дублировани кода получения возможных значений вынесем этот код в отдельный ActionFilter.</p>

<p>Модель:</p>

<pre><code>та же, что в предыдущем примере
</code></pre>

<p>ActionFilter:</p>

<pre><code>public class PopulateGenresAttribute: ActionFilterAttribute {
    public override void OnActionExecuted(ActionExecutedContext filterContext) {
        filterContext.Controller.ViewData["Genres"] = GetAllGenresFromDatabase();
    }
    //...
}    
</code></pre>

<p>Контроллер:</p>

<pre><code>public class MoviesController {
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
</code></pre>

<p>Плюсы, по сравнению с предыдущим решением.</p>

<ol><li>Устранено дублирование кода заполнения возможных значений</li>
</ol><p>Минусы</p>

<ol><li>Используется dynamic или magic-strings*, что не всегда положительно сказывается на возможности рефакторинга</li>
<li>Необходимо иметь по шаблону на каждый тип справочника</li>
</ol><h3>Улучшенное решение с использованием ViewBag / ViewData + <a href="http://mvcextensions.codeplex.com">MvcExtnsions</a></h3>

<p>В MvcExensions есть замечательные <a href="http://github.com/MvcExtensions/Core/blob/master/src/MvcExtensions/ModelMetadata/HtmlSelectModelMetadataItemBuilderExtensions.cs">методы для работы с drop-down list</a>: AsDropDownList / AsListBox (первый для выпадающего списка, второй для множественного выбора). Это методы-расширения для конструктора метаданных. Данные методы устанавливают шаблон и позволяют передать в шаблон название поля ViewBag, которое хранит данные с возможными значениями. Таким образом решается проблема с необходимостю иметь по шаблону на каждый справочник.</p>

<p>Модель:</p>

<pre><code>public class Movie {
    public int GenreId { get; set; }
} 
</code></pre>

<p>Метаданные:</p>

<pre><code>public class MovieMetadata : ModelMetadataConfiguration {
    public MovieMetadata {
        Configure(movie =&gt; movie.GenreId).AsDropDownList("Genres"/*шаблон*/);
    }
}
</code></pre>

<p>Контроллер:</p>

<pre><code>как в предыдущем примере.
</code></pre>

<p>Плюсы, по сравнению с предыдущим решением:</p>

<ol><li>Используется два универсальных шаблона (DropDownList / ListBox) для всех списков (есть возможность указать свой шаблон, если это необходимо)</li>
</ol><p>Минусы:</p>

<ol><li>Используется dynamic или magic-strings*, что не всегда положительно сказывается на возможности рефакторинга.</li>
</ol><h3>Решение с использованием ChildAction</h3>

<p>Если попытаться использовать child action &#8220;в лоб&#8221;, то это решение просто-напросто не будет работать: не будет работать клиенская валидация, не будут работать сценарии в случае сложных вложенных форм и т.д. В <a href="http://pashapash.com/2010/12/dropdown-v-asp-net-mvc-chast-1/">статье</a> (<a href="http://pashapash.com/2011/01/dropdown-v-asp-net-mvc-chast-2/">часть 2</a>) неизвестного автора (быстрый поиск выдал только <a href="http://habrahabr.ru/users/PashaPash/">профиль</a> на хабре) решены эти проблемы, и по-этому я буду рассматривать <em>окончательное решение автора</em>.</p>

<p>Модель</p>

<pre><code>public class Movie {
    [UIHint("Genres")]
    public int GenreId { get; set; }
} 
</code></pre>

<p>Контроллеры:</p>

<pre><code>public class MoviesController {
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
</code></pre>

<p>Плюсы, по сравнению, с решениями с ViewBag / ViewData</p>

<ol><li>Не используется dynamic или magic-strings</li>
<li>Устранено дублирование кода заполнения возможных значений</li>
</ol><p>Минусы</p>

<ol><li>Дублирование обслуживающего кода</li>
<li>Необходимо иметь по шаблону на каждый тип справочника</li>
<li>Не поддерживается сценарий Post-Redirect-Get</li>
</ol><h3>Решение с использованием ChildAction + MvcExtensions</h3>

<p>Я решил, усовершенствовать последнее решение и применить опыт использования ActionFilter, и теперь, с версии <a href="http://nuget.org/packages/MvcExtensions">2.5.0-rc8000 в MvcExtensions</a> поддерживаются выпадающие списки &#8220;из коробки&#8221;. Были добавлены методы расширения, позволяющие указывать, что для отображения данного поля модели необходимо вызвать ChildAction. Также был добавлен <code>SelectListActionAttribute</code>, который занимается обслуживанием метода, предоставлюящего возможнные значения для выпадающего списка. Поддерживается Post-Redirect-Get</p>

<p>Модель:</p>

<pre><code>public class Movie {
    public int GenreId { get; set; }
} 
</code></pre>

<p>Метаданные:</p>

<pre><code>public class MovieMetadata : ModelMetadataConfiguration {
    public MovieMetadata {
        Configure(movie =&gt; movie.GenreId).RenderAction("List", "Genres");
    }
}
</code></pre>

<p>Контроллеры:</p>

<pre><code>public class MoviesController {
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
</code></pre>

<p>Плюсы, по сравнению с предыдущими решениями</p>

<ol><li>Устранено дублирование обслужвающего кода</li>
<li>Используется единый шаблон</li>
<li>MultiSelect &#8220;из коробки&#8221;</li>
<li>Поддерживается сценарий Post-Redirect-Get</li>
</ol><h1>Вместо заключения.</h1>

<p>Для меня, как одного из разработчиков MvcExtensions варианты с использованием этой библиотеки предпочтительнее.</p>

<p>Пример кода для варианта с ViewBag / ViewData + MvcExtensions здесь: <a href="http://github.com/MvcExtensions/Core/tree/master/samples">http://github.com/MvcExtensions/Core/tree/master/samples</a></p>

<p>Пример кода для варианта с ChildAction + MvcExtensions здесь: <a href="http://github.com/hazzik/DropDowns">http://github.com/hazzik/DropDowns</a></p>

<hr><p>*magic-strings легко побеждаются, использованием констант, и по-этому для меня в данном контексте предпочтительней, чем dynamic</p>

<p>PS: Возможности MvcExtensions для расширения старого доброго ASP.NET MVC просто безграничны.</p>
