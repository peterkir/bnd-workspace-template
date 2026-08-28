---
layout: default
title: Semantic Templates
nav_exclude: true
---

# Semantic Code Templates — osgi-test

Generated from [templates.json](templates.json).

Placeholder rule: an occurrence of `${...}` is a **parameter iff its name appears in the
template's legend**. Anything else (`${classes...}`, `${junit}`, `${workspace}`) is literal
bnd macro syntax — copy unchanged.

## 1. `osgi-junit5-test-class` — JUnit5 in-framework test with injection

```java
package ${test-package};

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.osgi.framework.BundleContext;
import org.osgi.test.common.annotation.InjectBundleContext;
import org.osgi.test.common.annotation.InjectService;
import org.osgi.test.common.service.ServiceAware;
import org.osgi.test.junit5.context.BundleContextExtension;
import org.osgi.test.junit5.service.ServiceExtension;

@ExtendWith(BundleContextExtension.class)
@ExtendWith(ServiceExtension.class)
class ${test-class-name} {

	@InjectBundleContext
	BundleContext bundleContext;

	@InjectService
	${service-type} service;

	@Test
	void ${test-method-name}() {
		assertThat(service).isNotNull();
		// exercise ${service-type} contract here
	}

	@Test
	void dynamicArrival(@InjectService(cardinality = 0) ServiceAware<${service-type}> aware) {
		assertThat(aware.getServices()).hasSize(${expected-count});
	}
}
```

| Param | Type | Example |
|---|---|---|
| `test-package` | java package | `com.acme.player.test` |
| `test-class-name` | java identifier | `PlayerTest` |
| `service-type` | java type | `Player` |
| `test-method-name` | java identifier | `playerKicksBall` |
| `expected-count` | int | `1` |

## 2. `osgi-integration-test-bndrun` — integration-test launch descriptor

```properties
-tester: biz.aQute.tester.junit-platform

-runvm: -enableassertions:${assert-package-prefix}...

-runfw: org.eclipse.osgi
-resolve.effective: active
-runproperties: \
	osgi.console=

-runrequires: \
	bnd.identity;id='${tests-bundle-id}'

-runstartlevel: \
	order=sortbynameversion,\
	begin=-1
# -runbundles computed by resolver: bnd resolve resolve -W -b <this file>
```

| Param | Type | Example |
|---|---|---|
| `assert-package-prefix` | package prefix | `com.acme` |
| `tests-bundle-id` | BSN | `com.acme.player-tests` |

## 3. `osgi-test-project-bnd` — bnd workspace test project

```properties
Bundle-Description: ${description}

Test-Cases: ${classes;HIERARCHY_INDIRECTLY_ANNOTATED;org.junit.platform.commons.annotation.Testable;CONCRETE}

-dependson: \
	${impl-project-bsn}

-buildpath: \
	osgi.core;version=${osgi-core-version};maven-scope=provided,\
	${api-project-bsn};version=snapshot,\
	${junit},\
	${osgitest}
```

| Param | Type | Example |
|---|---|---|
| `description` | string | `Player integration tests` |
| `impl-project-bsn` | BSN | `com.acme.player.impl` |
| `api-project-bsn` | BSN | `com.acme.player.api` |
| `osgi-core-version` | version | `8.0.0` |

`${classes...}`, `${junit}`, `${osgitest}` are bnd macros — literal.

## 4. `osgi-assertj-custom-assert` — AssertJ assertion pair

```java
public abstract class Abstract${type-simple-name}Assert<SELF extends Abstract${type-simple-name}Assert<SELF, ACTUAL>, ACTUAL extends ${type-fqn}>
	extends AbstractAssert<SELF, ACTUAL> {

	protected Abstract${type-simple-name}Assert(ACTUAL actual, Class<SELF> selfType) {
		super(actual, selfType);
	}

	public SELF ${assertion-method}(${assertion-arg-type} expected) {
		isNotNull();
		if (!actual.${actual-getter}().equals(expected)) {
			throw failureWithActualExpected(actual.${actual-getter}(), expected,
				"%nExpecting %s to have ${assertion-property} %s but was %s", actual, expected, actual.${actual-getter}());
		}
		return myself;
	}
}

public class ${type-simple-name}Assert extends Abstract${type-simple-name}Assert<${type-simple-name}Assert, ${type-fqn}> {

	public static final InstanceOfAssertFactory<${type-fqn}, ${type-simple-name}Assert> ${factory-constant} = new InstanceOfAssertFactory<>(
		${type-fqn}.class, ${type-simple-name}Assert::assertThat);

	public ${type-simple-name}Assert(${type-fqn} actual) {
		super(actual, ${type-simple-name}Assert.class);
	}

	public static ${type-simple-name}Assert assertThat(${type-fqn} actual) {
		return new ${type-simple-name}Assert(actual);
	}
}
```

| Param | Type | Example |
|---|---|---|
| `type-simple-name` | java identifier | `Bundle` |
| `type-fqn` | java type | `Bundle` |
| `factory-constant` | java constant | `BUNDLE` |
| `assertion-method` | java identifier | `hasSymbolicName` |
| `assertion-arg-type` | java type | `String` |
| `actual-getter` | java identifier | `getSymbolicName` |
| `assertion-property` | string | `symbolic name` |
