## Overview 

`Concordion` transforms your boring unit tests into beautiful specification documents! It is similar to [Cucumber](http://cukes.info/) but focuses on readability and presentation.

`Concordion` embeds test results directly into your test documentation, giving it real *meaning*.

Features:

- **Pretty** - creates beautiful HTML output.
- **Simple** - run Concordion tests with [fant](http://fantom.org/doc/docTools/Fant.html), just like a unit test!
- **Linkable** - create organised and hierarchical index pages with the `run` command.
- **Extensible** - write your own commands with ease.
- **Skinnable** - Customise your HTML reports as you see fit.

For a live example of Concordion results, see the output from the [Java Concordion framework](http://concordion.org/dist/1.4.4/spec/concordion/Concordion.html).

## Install 

Install `Concordion` with the Fantom Repository Manager ( [fanr](http://fantom.org/doc/docFanr/Tool.html#install) ):

    C:\> fanr install -r http://repo.status302.com/fanr/ afConcordion

To use in a [Fantom](http://fantom.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afConcordion 0.0+"]

## Documentation 

Full API & fandocs are available on the [Status302 repository](http://repo.status302.com/doc/afConcordion/).

## Quick Start 

1). Create a text file called `HelloWorldFixture.fan`

```
using afConcordion

** My First Fixture
** ################
**
** This is a simple Concordion fixture that verifies that the method
** 'greeting()' returns 'Hello World!'.
**
** Example
** -------
** Concordion says, [Hello World!]`verify:eq(greeting)`
**
class HelloWorldFixture : FixtureTest {
    Str greeting() {
        "Hello World!"
    }
}
```

2). Run `HelloWorldFixture.fan` as a Fantom test script ( [fant](http://fantom.org/doc/docTools/Fant.html) ) from the command prompt:

```
C:\> fant HelloWorldFixture.fan

-- Run:  HelloWorldFixture_0::HelloWorldFixture.testConcordionFixture...
   Pass: HelloWorldFixture_0::HelloWorldFixture.testConcordionFixture [0]

[info] [afConcordion] file:/C:/temp/concordion/HelloWorldFixture.html

Time: 691ms

***
*** All tests passed! [1 tests, 1 methods, 1 verifies]
***
```

3). View the generated fixture result file:

![Screenshot of Hello World Fixture Results](http://static.alienfactory.co.uk/fantom-docs/afConcordion.helloWorldFixture.png)

The green highlight means the test passed.

Try changing `Hello World!` to something else and re-run the test to watch it fail.

Then have `greeting()` throw an Err... See the stacktrace embedded in the result!

## Terminology 

An **Acceptance Test** is a standard Fantom Test that has been enhanced to verify real user requirements.

The **Fixture** is the code part of the *acceptance test* that does the actual work.

**Specification** refers to the documentation part of the *acceptance test*.

**Commands** are special links in the *specification* that drive the test, specifying input and verifying output.

## Usage 

Any Fantom class annotated with the [@Fixture](http://repo.status302.com/doc/afConcordion/Fixture.html) facet can be run as a Concordion fixture. Just pass it into `ConcordionRunner.runFixture()`:

```
using afConcordion

** My first Concordion fixture.
@Fixture
class MyFixture {
    ...
}

fixture := MyFixture()
runner  := ConcordionRunner()
runner.runFixture(fixture)
```

[ConcordionRunner](http://repo.status302.com/doc/afConcordion/ConcordionRunner.html) is designed to be subclassed and has several methods, or hooks, that change it's behaviour:

- `suiteSetup()` is only ever called once no matter how many fixtures are run, or `ConcordionRunners` created.
- `suiteTearDown()` again is only ever called the once (currently in an Env shutdown hook).
- `fixtureSetup()` is called before every fixture.
- `fixtureTearDown()` is called after every fixture.
- `skinType` & `gimmeSomeSkin()` determine & create an instance of the `ConcordionSkin` class used to render the result HTML. You could, for instance, change this to use a Bootstrap skin.
- `outputDir` is where the result files are saved.
- `commands` is a map of all the [Commands](http://repo.status302.com/doc/afConcordion/Commands.html) made available to the test. To extend Concordion, simply add your own Command implementation to the map! (Super easy!)

To help you bridge the gap between Concordion and standard Fantom tests, Concordion ships with [FixtureTest](http://repo.status302.com/doc/afConcordion/FixtureTest.html). This handy class lets you run any Fixture as a Fantom Test.

To use a specific `ConcordionRunner` in your tests, override `concordionRunner()` to return desired instance. Even though all your tests will extend `FixtureTest`, the `concordionRunner()` method will only be called once. This means you can run a single test with [fant](http://fantom.org/doc/docTools/Fant.html), or all of them, and they will still only use the same runner instance.

## Specifications 

Specifications are documents written in Fantom's own [Fandoc](http://fantom.org/doc/fandoc/index.html) format, similar to [Markdown](http://daringfireball.net/projects/markdown/) and [Almost Plain Text](http://maven.apache.org/doxia/references/apt-format.html).

By marking text in the specification as links, you turn them into commands. Your specification can now be thought of as a simple script.

When you run the specification script, the Fandoc is converted into HTML and the commands executed as they are encountered. The commands generate HTML markup to show whether they passed or failed.

By default the specification is assumed to be the doc comment on the fixture:

```
** This comment is the specification.
@Fixture
class MyFixture { }
```

By doing so, every line in the doc comment must start with a double asterisk `**`. The specification may exist in its own file, just give a URL to its location in the `@Fixture` facet:

```
** This comment is the specification.
@Fixture { specification=`/myproj/specs/Spec1.fandoc` }
class MyFixture { }
```

Specifications, when they exist in their own file, do *not* start each line with a double asterisk `**`.

> TIP: Use [Fandoc Viewer](http://www.fantomfactory.org/pods/afFandocViewer) to edit fandoc files and specifications.

Specifications can be written in any way you wish, but the following structure is very useful. It is written here as a fandoc comment so you may cut and paste it into your specifications.

```
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
```

## Commands 

### set 

The `set` command sets a field of the fixture to the value of the link text. The `Str` is [coercered](http://repo.status302.com/doc/afBeanUtils/TypeCoercer.html) to the field's type.

```
** The meaning of life is [42]`set:number`.
@Fixture
class ExampleFixture {
  Int? number
}
```

### execute 

The `execute` command calls a method on the fixture. The cmd is compiled as Fantom code so may be *any* valid Fantom code.

Any occurrences of the token `#TEXT` are replaced with the command / link text.

```
** [The end has come.]`execute:initiateShutdownSequence(42, #TEXT, "/tmp/end.txt".toUri)`
@Fixture
class ExampleFixture {
  Void initiateShutdownSequence(Int num, Str cmdText, Uri url) {
    ...
  }
}
```

### verify 

The `verify` command executes a Test verify method against the link text. Available verify methods are:

- eq(...)
- notEq(...)
- type(...)
- true(...)
- false(...)
- null(...)
- notNull(...)

Arguments to the verify methods are run against the fixture and may be any valid Fantom code.

```
** The meaning of life is [42]`verify:eq(number)`.
@Fixture
class ExampleFixture {
  Int? number := 43
}
```

Arguments for the `eq()` and `notEq()` methods are [type coerced](http://repo.status302.com/doc/afBeanUtils/TypeCoercer.html) to a `Str`. Arguments for the `true()` and `false()` are [type coerced](http://repo.status302.com/doc/afBeanUtils/TypeCoercer.html) to a `Bool`.

### fail 

This simple command fails the test with the given message.

```
** The meaning of life is [42]`fail:TODO`.
@Fixture
class ExampleFixture { }
```

### run 

The `run` command runs another Concordion fixture and prints an appropriate success / failure link to it.

The command path must be the name of the Fixture type to run. The fixture type may be qualified.

Use `run` commands to create a specification containing a list of all acceptance tests for a feature, in a similar way you would use a test suite.

You could even nest specifications to form a hierarchical index, with results aggregated to display a single green / red / grey result.

```
** Questions:
** - [Why is the sky blue?]`run:BlueSkyFixture`.
@Fixture
class ExampleFixture { }
```

### link 

The `link` command renders a standard HTML <a> tag. It is added with the `file`, `http`, `https` and `mailto` schemes.

```
** Be sure to check out [Fantom-Factory]`http://www.fantomfactory.org/`.
@Fixture
class ExampleFixture { }
```

### embed 

The `embed` command executes the given function against the fixture and embeds the results as raw HTML.

Use it to add extra markup to your fixtures.

```
** Kids, don't play with [FIRE!]`embed:danger(#TEXT)`.
@Fixture
class ExampleFixture {
  Str danger(Str text) {
    """<span class="danger">${text}</span>"""
  }
}
```

## Test BedSheet Apps 

Concordion can be used to test BedSheet applications.

Typically I would start the web application under test (via [Bounce](http://www.fantomfactory.org/pods/afBounce)) in the runner's `suiteSetup()`. Since all web application state is (usually) stored in a database, there is little need to re-start the web app for every test. While this only saves you a couple of seconds, over the course of many tests it can add up to be quite a time saver!

Web application shutdown would then occur in the runner's `suiteTearDown()` method.

Below shows a typical ConcordionRunner setup together with an abstract WebFixture class.

```
using afBounce
using afConcordion

class MyConcordionRunner : ConcordionRunner {
    private BedServer? server

    new make(|This|? f := null) : super(f) {
        outputDir = `concordion-results/`.toFile

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
        server.injectIntoFields(webFixture)
        webFixture.fixtureSetup()
    }

    override Void fixtureTearDown(Obj fixtureInstance, FixtureResult result) {
        webFixture := ((WebFixture) fixtureInstance)

        webFixture.fixtureTearDown
        super.fixtureTearDown(fixtureInstance, result)
    }
}

class WebTestModule {

    @Contribute { serviceType=ServiceOverrides# }
    static Void contributeServiceOverride(MappedConfig config) {
        config["IocEnv"] = IocEnv.fromStr("Testing")
    }

    // other test specific services and overrides...
}

// The super class for all Web Fixtures
abstract class WebFixture : FixtureTest {
    BedClient? client

    virtual Void fixtureSetup() { }
    virtual Void fixtureTearDown() { }

    // The important bit - this creates the ConcordionRunner to be used.
    override ConcordionRunner concordionRunner() {
        MyConcordionRunner()
    }

    // Other common / reusable methods such as :
    // loginAs(...), logout(), gotoPage(...), etc...
}
```

