---
layout: default
title: Canonical Implementations
nav_exclude: true
---

# Canonical Implementations — osgi-test

Generated from [implementations.json](implementations.json). All excerpts pinned to commit `696b03cd`.
★ = primary exemplar per pattern.

## annotation-driven-injection

### ★ InjectBundleContext.java (L61-L68)

[permalink](https://github.com/eclipse-osgi-technology/osgi-test/blob/696b03cd2eaf4e91f7ad0e3d424e4bebb28525ce/org.osgi.test.junit5/src/main/java/org/osgi/test/common/annotation/InjectBundleContext.java#L61-L68)
— smallest complete instance: marker annotation whose `@ExtendWith` meta-annotation self-registers the extension.

```java
@Inherited
@Target({
	FIELD, PARAMETER
})
@Retention(RUNTIME)
@ExtendWith(BundleContextExtension.class)
@Documented
public @interface InjectBundleContext {}
```

### InjectService.java (L56-L90)

[permalink](https://github.com/eclipse-osgi-technology/osgi-test/blob/696b03cd2eaf4e91f7ad0e3d424e4bebb28525ce/org.osgi.test.junit5/src/main/java/org/osgi/test/common/annotation/InjectService.java#L56-L90)
— configurable variant: filter/cardinality/timeout as members with defaults.

```java
@Inherited
@Target({
	FIELD, PARAMETER
})
@Retention(RUNTIME)
@ExtendWith(ServiceExtension.class)
@Documented
public @interface InjectService {

	static long DEFAULT_TIMEOUT = 200l;

	String filter() default "";

	String[] filterArguments() default {};

	int cardinality() default 1;

	long timeout() default DEFAULT_TIMEOUT;
}
```

## generic-injecting-extension

### ★ InjectingExtension.java (L50-L93)

[permalink](https://github.com/eclipse-osgi-technology/osgi-test/blob/696b03cd2eaf4e91f7ad0e3d424e4bebb28525ce/org.osgi.test.junit5/src/main/java/org/osgi/test/junit5/inject/InjectingExtension.java#L50-L93)
— the reusable core: five lifecycle interfaces implemented once.

```java
public abstract class InjectingExtension<INJECTION extends Annotation>
	implements BeforeEachCallback, BeforeAllCallback, ParameterResolver, AfterAllCallback, AfterEachCallback {

	private final Class<INJECTION>	annotation;
	private final List<Class<?>>	targetTypes;

	protected InjectingExtension(Class<INJECTION> annotation, Class<?>... targetTypes) {
		this.annotation = requireNonNull(annotation);
		this.targetTypes = Arrays.asList(targetTypes);
	}

	@Override
	public void beforeAll(ExtensionContext extensionContext) throws Exception {
		List<Field> fields = findAnnotatedFields(extensionContext.getRequiredTestClass(), annotation(),
			m -> Modifier.isStatic(m.getModifiers()));

		fields.stream()
			.filter(field -> supportsField(field, extensionContext))
			.forEach(field -> setField(field, null, resolveField(field, extensionContext)));
		if (isLifecyclePerClass(extensionContext)) {
			injectNonStaticFields(extensionContext, extensionContext.getRequiredTestInstance());
		}
	}

	@Override
	public void beforeEach(ExtensionContext extensionContext) throws Exception {
		if (!isLifecyclePerClass(extensionContext)) {
			injectNonStaticFields(extensionContext, extensionContext.getRequiredTestInstance());
		}
	}
```

### BundleContextExtension.java (L60-L72)

[permalink](https://github.com/eclipse-osgi-technology/osgi-test/blob/696b03cd2eaf4e91f7ad0e3d424e4bebb28525ce/org.osgi.test.junit5/src/main/java/org/osgi/test/junit5/context/BundleContextExtension.java#L60-L72)
— minimal concrete subclass.

```java
public class BundleContextExtension extends InjectingExtension<InjectBundleContext> {

	public static final String BUNDLE_CONTEXT_KEY = "bundle.context";

	public BundleContextExtension() {
		super(InjectBundleContext.class, BundleContext.class);
	}

	@Override
	protected Object resolveValue(TargetType targetType, InjectBundleContext injection,
		ExtensionContext extensionContext) throws ParameterResolutionException {
		return getBundleContext(extensionContext);
	}
}
```

## store-scoped-cleanup

### ★ BundleContextExtension.java (L74-L126)

[permalink](https://github.com/eclipse-osgi-technology/osgi-test/blob/696b03cd2eaf4e91f7ad0e3d424e4bebb28525ce/org.osgi.test.junit5/src/main/java/org/osgi/test/junit5/context/BundleContextExtension.java#L74-L126)
— lazy store creation, CloseableResource wrapper, parent-context walk, proxy cleanup.

```java
public static BundleContext getBundleContext(ExtensionContext extensionContext) {
	BundleContext bundleContext = getStore(extensionContext)
		.getOrComputeIfAbsent(BUNDLE_CONTEXT_KEY,
			key -> new CloseableResourceBundleContext(getParentBundleContext(extensionContext)),
			CloseableResourceBundleContext.class)
		.get();
	return bundleContext;
}

private static BundleContext getParentBundleContext(ExtensionContext extensionContext) {
	BundleContext parentContext = extensionContext.getParent()
		.filter(context -> context.getTestClass()
			.isPresent())
		.map(BundleContextExtension::getBundleContext)
		.orElseGet(() -> ContextHelper.getBundleContext(extensionContext.getRequiredTestClass()));
	return parentContext;
}

public static class CloseableResourceBundleContext implements CloseableResource {

	private final BundleContext bundleContext;

	CloseableResourceBundleContext(BundleContext bundleContext) {
		this.bundleContext = CloseableBundleContext.proxy(bundleContext);
	}

	@Override
	public void close() throws Exception {
		((AutoCloseable) get()).close();
	}
}

static Store getStore(ExtensionContext extensionContext) {
	return extensionContext
		.getStore(Namespace.create(BundleContextExtension.class, extensionContext.getUniqueId()));
}
```

## in-framework-testing

### ★ org.osgi.test.junit5/test.bndrun (L17-L45)

[permalink](https://github.com/eclipse-osgi-technology/osgi-test/blob/696b03cd2eaf4e91f7ad0e3d424e4bebb28525ce/org.osgi.test.junit5/test.bndrun#L17-L45)
— complete launch descriptor; `-runbundles` resolver-computed.

```properties
-tester: biz.aQute.tester.junit-platform

-runvm: -enableassertions:org.osgi.test...,\
	${def;argLine}

-runfw: org.eclipse.osgi
-resolve.effective: active
-runproperties: \
	logback.configurationFile='${fileuri;${.}/logback.xml}',\
	org.osgi.framework.bootdelegation='sun.misc,sun.reflect',\
	osgi.console=

-runpath: \
	ch.qos.logback.classic,\
	ch.qos.logback.core,\
	org.apache.felix.logback,\
	slf4j.api
-runrequires: \
	bnd.identity;id='${project.artifactId}-tests'
# This will help us keep -runbundles sorted
-runstartlevel: \
    order=sortbynameversion,\
    begin=-1
# -runbundles is calculated by the bnd-resolver-maven-plugin
```

### example player.test/bnd.bnd (L1-L17)

[permalink](https://github.com/eclipse-osgi-technology/osgi-test/blob/696b03cd2eaf4e91f7ad0e3d424e4bebb28525ce/examples/osgi-test-example-bndworkspace/org.osgi.test.example.player.test/bnd.bnd#L1-L17)
— bnd-workspace variant with `Test-Cases` discovery macro.

```properties
-include: ${workspace}/cnf/includes/jdt.bnd

Bundle-Description: OSGi Testing Example Player Test

Test-Cases: ${classes;HIERARCHY_INDIRECTLY_ANNOTATED;org.junit.platform.commons.annotation.Testable;CONCRETE}

-dependson: \
	org.osgi.test.example.player.impl

-buildpath: \
	osgi.core;version=8.0.0;maven-scope=provided,\
	org.osgi.namespace.service;version=1.0.0;maven-scope=provided,\
	org.osgi.test.example.api;version=snapshot,\
	${junit},\
	${mockito},\
	${osgitest}
```

## assertj-per-domain-module

### ★ BundleAssert.java (L19-L36)

[permalink](https://github.com/eclipse-osgi-technology/osgi-test/blob/696b03cd2eaf4e91f7ad0e3d424e4bebb28525ce/org.osgi.test.assertj.framework/src/main/java/org/osgi/test/assertj/bundle/BundleAssert.java#L19-L36)
— canonical AssertJ leaf class.

```java
public class BundleAssert extends AbstractBundleAssert<BundleAssert, Bundle> {

	public static final InstanceOfAssertFactory<Bundle, BundleAssert> BUNDLE = new InstanceOfAssertFactory<>(
		Bundle.class, BundleAssert::assertThat);

	public BundleAssert(Bundle actual) {
		super(actual, BundleAssert.class);
	}

	public static BundleAssert assertThat(Bundle actual) {
		return new BundleAssert(actual);
	}
}
```

## triple-example-consumption

### ★ PlayerTest.java (L46-L97)

[permalink](https://github.com/eclipse-osgi-technology/osgi-test/blob/696b03cd2eaf4e91f7ad0e3d424e4bebb28525ce/examples/osgi-test-example-bndworkspace/org.osgi.test.example.player.test/src/org/osgi/test/example/player/test/PlayerTest.java#L46-L97)
— complete consumer-side test: static + instance injection, `ServiceAware`, `DictionaryAssert`.

```java
@ExtendWith(BundleContextExtension.class)
@ExtendWith(ServiceExtension.class)
public class PlayerTest {

	static Ball b;

	@InjectBundleContext
	BundleContext bc;

	@BeforeAll
	static void beforeAll(@InjectBundleContext BundleContext staticBC) {
		b = mock(Ball.class);
		Dictionary<String, Object> props = Dictionaries.dictionaryOf("test", "testball");
		staticBC.registerService(Ball.class, b, props);
	}

	@InjectService
	Player p;

	@Test
	void myTest() {
		assertThat(p).isNotNull();
		assertThat(p.getBall()).isSameAs(b);
		verifyNoInteractions(b);
		p.kickBall();
		verify(b).kick();
	}

	@Test
	void myServiceAwareTest(@InjectService(cardinality = 0) ServiceAware<Ball> ball) {
		assertThat(ball.getServices()).hasSize(1);
		DictionaryAssert.assertThat(ball.getServiceReference()
			.getProperties())
			.containsEntry("test", "testball");
		bc.registerService(Ball.class, new DummyBall(), null);
		assertThat(ball.getServices()).hasSize(2);
	}
}
```
