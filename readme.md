# Fancordion v1.1.6
---

[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](https://fantom-lang.org/)
[![pod: v1.1.6](http://img.shields.io/badge/pod-v1.1.6-yellow.svg)](http://eggbox.fantomfactory.org/pods/afFancordion)
[![Licence: ISC](http://img.shields.io/badge/licence-ISC-blue.svg)](https://choosealicense.com/licenses/isc/)

## Overview

Fancordion is a tool for creating automated acceptance tests, transforming your boring unit tests into beautiful specification documents! It is similar to [Cucumber](http://cukes.info/) but focuses on readability and presentation.

Fancordion embeds test results directly into your test documentation, giving it real *meaning*.

Features:

* **Pretty**     - creates beautiful HTML output.
* **Simple**     - run Fancordion tests with [fant](https://fantom.org/doc/docTools/Fant.html), just like a unit test!
* **Linkable**   - create organised and hierarchical result pages.
* **Extensible** - write your own custom commands with ease.
* **Skinnable**  - customise your HTML reports as you see fit.


![Fancordion Example](http://eggbox.fantomfactory.org/pods/afFancordion/doc/exampleScreenshot.png)

Fancordion was inspired by Java's [Concordion](http://concordion.org/).

For a great explanation of how to write great acceptance tests, along with do's and don't's, see [Hints and Tips](http://concordion.org/Technique.html) on the Concordion website.

## <a name="Install"></a>Install

Install `Fancordion` with the Fantom Pod Manager ( [FPM](http://eggbox.fantomfactory.org/pods/afFpm) ):

    C:\> fpm install afFancordion

Or install `Fancordion` with [fanr](https://fantom.org/doc/docFanr/Tool.html#install):

    C:\> fanr install -r http://eggbox.fantomfactory.org/fanr/ afFancordion

To use in a [Fantom](https://fantom-lang.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afFancordion 1.1"]

## <a name="documentation"></a>Documentation

Full API & fandocs are available on the [Eggbox](http://eggbox.fantomfactory.org/pods/afFancordion/) - the Fantom Pod Repository.

## Quick Start

1. Create a text file called `HelloWorldFixture.fan`    using afFancordion
    
    ** My First Fixture
    ** ################
    **
    ** This is a simple Fancordion fixture that verifies that the method
    ** 'greeting()' returns 'Hello World!'.
    **
    ** Example
    ** -------
    ** Fancordion says, [Hello World!]`verifyEq:greeting()`
    **
    class HelloWorldFixture : FixtureTest {
        Str greeting() {
            "Hello World!"
        }
    }


2. Run `HelloWorldFixture.fan` as a Fantom test script ( [fant](https://fantom.org/doc/docTools/Fant.html) ) from the command prompt:    C:\> fant HelloWorldFixture.fan
    
    -- Run:  HelloWorldFixture_0::HelloWorldFixture.testFancordionFixture...
       Pass: HelloWorldFixture_0::HelloWorldFixture.testFancordionFixture [0]
    
    [info] [afFancordion] C:\temp\fancordion\from-script\HelloWorldFixture.html ... Ok
    
    Time: 691ms
    
    ***
    *** All Fixtures Passed! [1 Fixtures]
    ***


3. View the generated fixture result file:
    ![Screenshot of Hello World Fixture Results](http://eggbox.fantomfactory.org/pods/afFancordion/doc/helloWorldFixture.png)



The green highlight means the test passed.

Try changing `Hello World!` to something else and re-run the test to watch it fail.

Then have `greeting()` throw an Err... See the stacktrace embedded in the result!

## Terminology

An **Acceptance Test** is a standard Fantom Test that has been enhanced to verify real user requirements.

The **Fixture** is the code part of the *acceptance test* that does the actual work.

**Specification** refers to the documentation part of the *acceptance test*.

**Commands** are special links in the *specification* that drive the test, specifying input and verifying output.

See [What is TDD, BDD & ATDD?](http://assertselenium.com/2012/11/05/difference-between-tdd-bdd-atdd/) for the differences between *Test Driven* Development, *Behaviour Driven* Development & *Acceptance Test Driven* Development.

## Usage

### Run as Fantom Class

Any Fantom class annotated with the [@Fixture](http://eggbox.fantomfactory.org/pods/afFancordion/api/Fixture) facet can be run as a Fancordion fixture. To run it, just pass it into `FancordionRunner.runFixture()`:

    using afFancordion
    
    ** My first Fancordion fixture.
    @Fixture
    class MyFixture {
        ...
    }
    
    fixture := MyFixture()
    runner  := FancordionRunner()
    runner.runFixture(fixture)
    

[FancordionRunner](http://eggbox.fantomfactory.org/pods/afFancordion/api/FancordionRunner) is designed to be subclassed and has several methods, or hooks, that change it's behaviour:

* `suiteSetup()` is only ever called once no matter how many fixtures are run, or `FancordionRunners` created.
* `suiteTearDown()` is only ever called the once (currently in an Env shutdown hook).
* `fixtureSetup()` is called before every fixture.
* `fixtureTearDown()` is called after every fixture.
* `skinType` & `gimmeSomeSkin()` determine & create an instance of the `FancordionSkin` class used to render the result HTML. You could, for instance, change this to use a Bootstrap skin.
* `outputDir` is where the result files are saved.
* `commands` is a map of all the [Commands](http://eggbox.fantomfactory.org/pods/afFancordion/api/Command) made available to the test. To extend Fancordion, simply add your own Command implementation to the map! (Super easy!)


### Run as a Fantom Test

Fancordion fixtures can also be run as standard Fantom tests.

To help you bridge the gap between Fancordion and Fantom tests, Fancordion ships with a handy [FixtureTest](http://eggbox.fantomfactory.org/pods/afFancordion/api/FixtureTest) class. Extending `FixtureTest` lets you run any Fixture as a Fantom Test.

    using afFancordion
    
    ** My first Fancordion fixture.
    class TestStuff : FixtureTest {
        ...
    }
    

To use a specific `FancordionRunner` in your tests, override `FixtureTest.fancordionRunner()` to return the desired instance. Even though all your tests will extend `FixtureTest`, the `fancordionRunner()` method will only be called once. This means you can run a single test with [fant](https://fantom.org/doc/docTools/Fant.html), or all of them, and they will still only use the same runner instance.

### Run from Pod

If you plan to run Fancordion tests from a pod, then you'll need to alter the `build.fan` slightly. By default, documentation for Test files are not included in a pod. This means your Fancordion tests loose their specifications. To re-include, add the following:

    using build
    using compiler
    
    class Build : BuildPod {
    
      ...
    
        override Void onCompileFan(CompilerInput ci) {
            ci.docTests = true
        }
    }
    

See the Fantom forum topic [Test Documentation](http://fantom.org/forum/topic/2283) for details.

Alternatively, you could include the Test source files in the pod.

## Specifications

Specifications are documents written in Fantom's own [Fandoc](https://fantom.org/doc/fandoc/index.html) format, similar to [Markdown](http://daringfireball.net/projects/markdown/) and [Almost Plain Text](http://maven.apache.org/doxia/references/apt-format.html).

By marking text in the specification as links, you turn them into commands. Your specification can now be thought of as a simple script.

When you run the specification script, the Fandoc is converted into HTML and the commands executed as they are encountered. The commands generate HTML markup to show whether they passed or failed.

By default the specification is assumed to be the doc comment on the fixture:

    ** This comment is the specification.
    @Fixture
    class MyFixture { }
    

By doing so, every line in the doc comment must start with a double asterisk `**`.

Specifications can be written in any way you wish, but the following structure is very useful. It is written here as a fandoc comment so you may cut and paste it into your specifications.

    ** Heading
    ** #######
    ** Give some background information and explain the problem at hand.
    **
    ** As a...
    ** When I...
    ** I want...
    **
    ** Example
    ** -------
    ** Now describe an example scenario and the expected behaviour. This will be the test:
    **
    ** Given...
    ** When...
    ** Then...
    **
    ** Only the example should contain commands.
    **
    ** Further Details
    ** ===============
    **  - [link to other fixtures here]`run:OtherTest`
    **  - [that explain edge cases]`run:MoreTests`
    

### Specifications Files

The specification may also exist in its own file. To do so, just ensure the Fixture / Test has *no* fandoc comment and Fancordion will walk the current directory tree looking for a file with the same name as the fixture, but with an extension of `.specificaion`, `.spec` or `.fandoc`.

You may also give a URL (relative or absolute) to its location in the `@Fixture` facet:

    ** This comment is the specification.
    @Fixture { specification=`/myproj/specs/Spec1.fandoc` }
    class MyFixture { }
    

Relative URLs are relative to the directory Fantom was started in. If the URL is a directory then a file with the same name as the fixture is looked for, but with an extension of `.specificaion`, `.spec` or `.fandoc`.

Note that specifications, when they exist in their own file, do *not* start each line with a double asterisk `**`.

> TIP: Use [Explorer App](http://eggbox.fantomfactory.org/pods/afExplorer) to edit fandoc files and specifications.


Specifications are looked up in the following order:

* from `@Fixture` Facet value
* from the Type's class level fandoc    + from the runtime loaded pod
    + from the `.fan` source file file on the file system
    + from the `.fan` source file file in the pod


* from an external specification file    + on the file system
    + in the pod




The exhaustive lookup proceedure allows Fancordion to run from IDEs such as [F4](http://www.xored.com/products/f4/); just ensure that the working directory is that of the project (and not the test) so file walking finds *all* the src and spec files:

    Run -> Run configurations... -> Test -> Arguments -> Working Directory

Note that when looking for source files, the source file **must** have the same name as the class.

## Command Syntax

All hyperlinks in a Fancordion specification are interpreted as commands. A standard fandoc hyperlink would look like:

    Remember, [Google]`http://www.google.com` is your friend

Fancordion hijacks this syntax and uses them as commands. Commands are generally broken down as:

    [text]`scheme:path`

The `text` is generally shown in the resulting HTML, the `scheme` is always the name of the command, and the `path` is contextual information passed to the command itself.

The exact nature or syntax of the `path` depends on / is different for each command, but often it is either a snippet of Fantom code or a plain string.

### Code

Commands such as `set`, `verify` and `execute` treat the `path` as a fantom expression that is run against the Fixture. So the command

    [wotever]`execute:echo("Hello!")`

would call the `echo()` method on your fixture.

Sometimes you don't want to run the expression against the fixture, sometimes the expression is a statement in its own right. That's fine, if the first part of the expression doesn't match against the slots on your fixture, it is taken to be a statement. Examples:

    [Stuff]`verifyEq:StrBuf().add("Stuff")`
    
    [value]`verifyEq:afBounce::Element("#id .class").text`

As shown above, when referencing classes not in `sys` or the same pod as the fixture, they need to be fully qualified.

### Macros

Fancordion lets you use some pre-defined macros, or constants, in your Fantom expressions. The most common macro is `#TEXT` which refers to the `text` part of the command. Guess what this command does: (!)

    [Mum!]`execute:echo("Hello " + #TEXT)`

The other common macro is `#FIXTURE` which lets you reference your fixture. So if your fixture had a field called `name`, you could print it with:

    [wotever]`execute:echo("Hello " + #FIXTURE.name)`

See the [table section](#tables) for other table specific macros.

Macro Summary:

    table:
    Macro       Type       Desc
    ----------  ---------  ---------------------------
    '#COL'      'Int'      Current table column index
    '#COL[0]'   'Str'      Table column
    '#COL[1]'   'Str'      Table column
    '#COL[2]'   'Str'      Table column
    '#COLS'     'Str[]'    Current table column array
    '#FIXTURE'  'Obj'      The fixture being run
    '#ROW'      'Int'      Current table row index
    '#ROW[0]'   'Str[]'    Table row
    '#ROW[1]'   'Str[]'    Table row
    '#ROW[2]'   'Str[]'    Table row
    '#ROWS'     'Str[][]'  Table array
    '#TEXT'     'Str'      Command text

Note all macros must be UPPER CASE.

### Aliases

Several command shortcut aliases are added by default.

    verifyEq      --> eq
    verifyNotEq   --> notEq
    verifyType    --> type
    verifyTrue    --> true
    verifyFalse   --> false
    verifyNull    --> null
    verifyNotNull --> notNull
    verifyErrType --> errType
    verifyErrMsg  --> errMsg
    execute       --> exe

The aliases may be used anywhere in place of the full command. Example:

    ** The meaning of life is [42]`eq:number`.
    class ExampleFixture : FixtureTest {
      Int? number := 43
    }
    

## Commands

The list of supported Fancordion commands.

### set

The `set` command sets a field in the fixture to the value of the link text. Example, this fixture command sets the `age` field to `42`:

    using afFancordion
    
    ** The meaning of life is [42]`set:age`.
    class ExampleFixture : FixtureTest {
      Int? age
    }
    

The property expression may be any valid Fantom expression, no matter how complex, as long as it references a field.

Note how in the above example the `Str` 42 is automatically [coercered](http://eggbox.fantomfactory.org/pods/afBeanUtils/api/TypeCoercer) to an `Int`. This is a useful feature, but is only available for simple, dot separated, expressions.

### <a name="execute"></a>execute

The `execute` command calls a method on the fixture. The cmd is compiled and executed as Fantom code:

    using afFancordion
    
    ** [Hello!]`execute:sayHello()`
    class ExampleFixture : FixtureTest {
      Void sayHello() {
        echo("Hello!")
      }
    }
    

`execute` cmds may use macros such as `#TEXT`, and / or pass parameters to methods. Here is a more complex example:

    using afFancordion
    
    ** [The end has come.]`execute:initiateShutdownSequence(42, #TEXT, "/tmp/end.txt".toUri)`
    class ExampleFixture : FixtureTest {
      Void initiateShutdownSequence(Int num, Str txt, Uri url) {
        // num = 42
        // txt = "The end has come."
        // url = `/tmp/end.txt`
      }
    }
    

### <a name="verify"></a>verify

The `verify` suite of commands execute a Test verify method against the link text. Available verify commands are:

* `verify`
* `verifyTrue`
* `verifyFalse`
* `verifyEq`
* `verifyNotEq`
* `verifyType`
* `verifyNull`
* `verifyNotNull`


Arguments to the verify methods are run against the fixture and may be any valid Fantom code.

    using afFancordion
    
    ** The meaning of life is [42]`verifyEq:number`.
    class ExampleFixture : FixtureTest {
      Int? number := 43
    }
    

Arguments for the `verifyEq` and `verifyNotEq` methods are [type coerced](http://eggbox.fantomfactory.org/pods/afBeanUtils/api/TypeCoercer) to a `Str` and trimmed. Arguments for the `verify`, `verifyTrue` and `verifyFalse` are [type coerced](http://eggbox.fantomfactory.org/pods/afBeanUtils/api/TypeCoercer) to a `Bool`.

### <a name="verifyErrType"></a>verifyErrType

Similar to [execute](#execute) except the expression *must* throw an Err of the specified type.

    using afFancordion
    
    ** This should throw an [sys::ArgErr]`verifyErrType:dodgyMethod()`.
    class ExampleFixture : FixtureTest {
    
        Void dodgyMethod() {
            throw ArgErr("Whoops")
        }
    }
    

Note that the Err Type may or may not be qualified, for example the test will match both `sys::ArgErr` and `ArgErr`.

The command will also strip any trailing `#` from the err type, allowing you to type `sys::ArgErr#` and `ArgErr#`, which feels more *code like*.

Any thrown Err is kept so you can subsequently check the msg:

    ** Throw an [ArgErr]`verifyErrType:dodgyMethod()` with the msg [Whoops!]`verifyErrMsg:`.
    

Note that to verify a previously thrown Err, leave the cmd path empty.

### verifyErrMsg

Similar to [verifyErrType](#verifyErrType) except that the Err *must* have the specified message.

    using afFancordion
    
    ** This should throw an Err with the msg [Whoops]`verifyErrMsg:dodgyMethod()`.
    class ExampleFixture : FixtureTest {
    
        Void dodgyMethod() {
            throw ArgErr("Whoops")
        }
    }
    

Any thrown Err is kept so you can subsequently check the type:

    ** The err should have the msg [Whoops]`verifyErrMsg:dodgyMethod()` and be of type [ArgErr]`verifyErrType:`.
    

Note that to verify a previously thrown Err, leave the cmd path empty.

### fail

This simple command fails the test with the given message. Example:

    using afFancordion
    
    ** The meaning of life is [42]`fail:TODO - Not Implemented`.
    class ExampleFixture : FixtureTest { }
    
    ...
    
    TEST FAILED
    sys::FailErr: TODO - Not Implemented
    

### run

The `run` command runs another Fancordion fixture and prints an appropriate success / failure link to it.

The command path must be the name of the Fixture type to run.

Use `run` commands to create a specification containing a list of all acceptance tests for a feature, in a similar way you would use a test suite.

You could even nest specifications to form a hierarchical index, with results aggregated to display a single green / red / grey result.

    using afFancordion
    
    ** Questions:
    ** - [Why is the sky blue?]`run:BlueSkyFixture#`.
    class ExampleFixture : FixtureTest { }
    

As seen above, the command path may take an optional `#` character as a suffix. This is the same syntax that Fantom has to specify Types. Using the `#` suffix can help you remember what the text represents! The fixture type may also be qualified.

### link

The `link` command renders a standard HTML `<a>` tag. It is added with the `file`, `http`, `https` and `mailto` schemes.

    using afFancordion
    
    ** Be sure to check out [Fantom-Factory]`http://www.fantomfactory.org/`.
    class ExampleFixture : FixtureTest { }
    

You can also link to other fixtures using the scheme `link` and the class name. Note the class name may, or may not be fully qualified.

    ** See also
    ** ========
    **  - [My other test]`link:OtherFixture#`
    

### embed

The `embed` command executes the given function against the fixture and embeds the results as raw HTML.

Use it to add extra markup to your fixtures.

    using afFancordion
    
    ** Kids, don't play with [FIRE!]`embed:danger(#TEXT)`.
    class ExampleFixture : FixtureTest {
      Str danger(Str text) {
        """<span class="danger">${text}</span>"""
      }
    }
    

### todo

`todo` simply ignores the command. Handy for commenting out tests.

    ** Questions:
    ** - [Why is the sky blue?]`todo:run:BlueSkyFixture#`.
    @Fixture
    class ExampleFixture { }
    

## Pre-Formatted Text

Pre-formatted text may be used as the input for commands by writing the command URL as the first line of the text:

    ** pre>
    ** verifyEq:errMsg
    ** This is the Err Msg.
    ** <pre
    

Note that pre-formatted text may also be any line indended by 2 or more spaces. Meaning the above may be re-written as:

    **   verifyEq:errMsg
    **   This is the Err Msg.
    

## <a name="tables"></a>Tables

Above and beyond normal [fandoc](https://fantom.org/doc/fandoc/index.html) syntax, Fancordion also has support for tables. (Yay!)

### Markup

To render a HTML table, use preformatted text with `table:` as the first line:

    ** pre>
    ** table:
    **
    ** Full Name    First Name  Last Name
    ** -----------  ----------  ---------
    ** John Smith   John        Smith
    ** Fred Bloggs  Fred        Bloggs
    ** Steve Eynon  Steve       Eynon
    ** <pre
    

Table parsing is simple, but expressive. The first line to start with a `-` character defines where the column boundaries are. All lines before are table headers, all lines after are table data.  Any lines consisting entirely of `-` or `+` characters are ignored.

That means the above table could also be written as:

    **   table:
    **   +-------------+-------+--------+
    **   |             | First | Last   |
    **   | Full Name   | Name  | Name   |
    **    -------------+-------+--------+
    **   | John Smith  | John  | Smith  |
    **   | Steve Eynon | Steve | Eynon  |
    **   | Fred Bloggs | Fred  | Bloggs |
    **   +-------------+-------+--------+
    

### Column Commands

You can specify commands for each column, to be run for each row. After the `table:` declaration, write commands on seperate lines prefixing them with `col[x]+` to specify on which column they should operate. Use the `#TEXT` macro to reference the text in the column / table cell.

The following example tests that each name can be split up into a first name and last name:

    using afFancordion
    
    ** Name Splitting
    ** ##############
    ** For personalalised mailshots, the system should be able
    ** to split a full name up into it's constituent parts.
    **
    ** Example:
    **
    **   table:
    **   col[0]+execute:split(#TEXT)
    **   col[1]+verifyEq:firstName
    **   col[2]+verifyEq:lastName
    **
    **   Full Name    First Name  Last Name
    **   -----------  ----------  ---------
    **   John Smith   John        Smith
    **   Fred Bloggs  Fred        Bloggs
    **   Steve Eynon  Steve       Eynon
    **
    class TestSplittingNames : FixtureTest {
        Str? firstName
        Str? lastName
    
        Void split(Str name) {
            firstName = name.split[0]
            lastName  = name.split[1]
        }
    }
    

There is also a special `col[n]` command which is run on every column. This command makes use of the `#COL` macro which relates to the (zero based) column index being processed. Example:

    col[n]+verifyEq:getDataForColumn(#COL)

### Row Commands

Similar to column commands, you can specify commands to be run on each row. Use the prefix `row+` when declaring a command.

Use the Fancordion macros `#COL[0]`, `#COL[1]`, `#COL[2]`, etc...  to reference the text in each column.

    using afFancordion
    
    ** Name Splitting
    ** ##############
    ** For personalalised mailshots, the system should be able
    ** to split a full name up into it's constituent parts.
    **
    ** Example:
    **
    **   table:
    **   row+execute:splitAndVerify(#COL[0], #COL[1], #COL[2])
    **
    **   Full Name    First Name  Last Name
    **   -----------  ----------  ---------
    **   John Smith   John        Smith
    **   Fred Bloggs  Fred        Bloggs
    **   Steve Eynon  Steve       Eynon
    **
    class TestSplittingNames : FixtureTest {
    
        Void splitAndVerify(Str full, Str first, Str last) {
            verifyEq(full.split[0], first)
            verifyEq(full.split[1],  last)
        }
    }
    

Use the `#ROW` macro to inject the 0-based index of the row being executed.

Use the `#ROWS` macro to inject a `Str[][]` array of the entire table. `#ROW[n]` may be used in a similar way to the `#COL[n]` cmds to inject individual rows. You may also use the `#COLS` macro to inject a `Str[]` list of all the column text in the current row.

Note: Using both column *and* row commands in a table is not allowed.

### Table Commands

`verifyRows` is a special table command that verifies that rows in the table are identical to a given list.

    using afFancordion
    
    **   table:
    **   verifyRows:results()
    **
    **   Names
    **   ------
    **   john
    **   ringo
    **   george
    **   paul
    **
    class VerifyRowsFixture : FixtureTest {
        Str[] results() {
            ["john", "ringo", "george", "paul"]
        }
    }
    

The fixture is marked as a failure should any item in the list not equal it's matching table row. Should the list contain too few or too many item, they are rendered as failures in the rendered HTML table.

`verifyRows` may also be applied to a 2D table, in which case a list of lists must be provided:

    using afFancordion
    
    **   table:
    **   verifyRows:results()
    **
    **   First  Last
    **   ------ ---------
    **   John   Lennon
    **   Ringo  Starr
    **   George Harrison
    **   Paul   McCartney
    **
    class VerifyRowsFixture : FixtureTest {
        Str[][] results() {
            [["John","Lennon], ["Paul","McCartney"], ["George","Harrison"], ["Ringo","Starr"]]
        }
    }
    

## Test BedSheet Apps

Fancordion can be used to test BedSheet applications.

Typically one would start the web application under test (via [Bounce](http://eggbox.fantomfactory.org/pods/afBounce)) in the runner's `suiteSetup()`. Since all web application state is (usually) stored in a database, there is little need to re-start the web app for every test. While this only saves you a couple of seconds, over the course of many tests it can add up to be quite a time saver!

Web application shutdown would then occur in the runner's `suiteTearDown()` method.

Below shows a typical `FancordionRunner` setup for a web app together with an abstract `WebFixture` class.

    using afIoc
    using afIocEnv
    using afBounce
    using afFancordion
    
    class MyFancordionRunner : FancordionRunner {
        private BedServer? server
    
        new make() {
            super.outputDir = `fancordion-results/`.toFile
    
            // other runner configuration...
        }
    
        override Void suiteSetup() {
            super.suiteSetup
            server = BedServer(AppModule#.pod).addModule(WebTestModule#).startup
        }
    
        override Void suiteTearDown(Type:FixtureResult resultsCache) {
            server?.shutdown
            super.suiteTearDown(resultsCache)
        }
    
        override Void fixtureSetup(Obj fixtureInstance) {
            webFixture := ((WebFixture) fixtureInstance)
    
            super.fixtureSetup(fixtureInstance)
            webFixture.client = server.makeClient
            server.inject(webFixture)
            webFixture.fixtureSetup()
        }
    
        override Void fixtureTearDown(Obj fixtureInstance, FixtureResult result) {
            webFixture := ((WebFixture) fixtureInstance)
    
            webFixture.fixtureTearDown
            super.fixtureTearDown(fixtureInstance, result)
        }
    }
    
    const class WebTestModule {
    
        @Override
        static IocEnv overrideIocEnv() {
            IocEnv.fromStr("Testing")
        }
    
        // other test specific services and overrides...
    }
    
    ** The super class for all Web Fixtures
    abstract class WebFixture : FixtureTest {
        BedClient? client
    
        virtual Void fixtureSetup() { }
        virtual Void fixtureTearDown() { }
    
        // The important bit - this creates the FancordionRunner to be used.
        override FancordionRunner fancordionRunner() {
            MyFancordionRunner()
        }
    
        // Other common / reusable methods such as :
        // loginAs(...), logout(), gotoPage(...), etc...
    }
    

A simple smoke test for a website then may look like:

    using afBounce::Element
    
    ** Smoke Test
    ** ##########
    ** Just a quick bimble about the website, making sure no errors appear.
    **
    ** Example
    ** -------
    ** 1. Goto [/]`exe:gotoUrl(#TEXT)`
    ** 1. Goto [/aboutMe]`exe:gotoUrl(#TEXT)`
    ** 1. Verify the title is [Mr Awesome!]`eq:h1.text`
    **
    class TestWebsite : WebFixture {
    
        override Void fixtureSetup() {
            client.webSession?.delete  // clear user session
        }
    
        Element h1() {
            Element("h1")
        }
    
        // ---- Useful Navigation Methods ----
    
        Void gotoUrl(Str pageUrl) {
            client.get(pageUrl.toUri)
        }
    
        // ---- User Debug Methods ----
    
        Str dumpPage() { echoPage }
        Str echoPage() { Element("html").html { echo(it) } }
    }
    

Note that most of the methods could, or rather should, be moved to `WebFixture` for reuse.

As your website grows, a common problem you may encounter when testing, is you visit *Page A* but through redirects or error handling, it is actually *Page B* that gets rendered. So just because no errors are thrown, it doesn't mean everything is okay.

If you're using [Pillow](http://eggbox.fantomfactory.org/pods/afPillow) then it's easy to assert that the page you visit, is the page rendered. Being able to use class names instead of URLs also makes your code more refactor friendly.

The following code is the same test, but written with Pillow in mind:

    using afBounce::Element
    using afPillow::Pages
    using afIoc::Inject
    
    ** Smoke Test
    ** ##########
    ** Just a quick bimble about the website, making sure no errors appear.
    **
    ** Example
    ** -------
    ** 1. Show the [Index Page]`exe:showPage(#TEXT)`
    ** 1. Show the [About Me Page]`exe:showPage(#TEXT)`
    ** 1. Verify the title is [Mr Awesome!]`eq:h1.text`
    **
    class TestWebsite : WebFixture {
    
        override Void fixtureSetup() {
            client.webSession?.delete  // clear user session
        }
    
        Element h1() {
            Element("h1")
        }
    
        // ---- Useful Navigation Methods ----
    
        Void showPage(Str pageName, Obj? ctx := null) {
            pageType := gotoPage(pageName, ctx)
            verifyEq(renderedPageType, pageType)
        }
    
        Type gotoPage(Str pageName, Obj? ctx := null) {
            pageType := Pod.of(this).type(pageName.fromDisplayName.capitalize)
            pageUrl     := ctx == null ? pages[pageType].pageUrl : pages[pageType].withContext(ctx is List ? ctx : [ctx]).pageUrl
            client.get(pageUrl)
            return pageType
        }
    
        Type renderedPageType() {
            Type.find(client.lastResponse.headers["X-afPillow-renderedPage"])
        }
    
        Str renderedPageName() {
            renderedPageType.name.toDisplayName
        }
    }
    

Again, most of the above methods should be moved to a common base class / mixin for reuse.

