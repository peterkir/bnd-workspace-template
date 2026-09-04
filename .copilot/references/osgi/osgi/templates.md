---
layout: default
title: osgi — templates
nav_exclude: true
---

<!-- Generated from templates.json — do not hand-edit -->

# Semantic Templates: osgi (osgi/osgi)

Parameter syntax: `${param-name}`. An occurrence is a parameter **iff** its name
appears in the template's legend — everything else (`${p}`, `${includes}`,
`${osgi.annotation.buildpath}`, `${-signaturetest}`) is literal bnd macro syntax.

## 1. `api-bundle-bnd` — Specification API project bnd.bnd

```properties
# Set javac settings from JDT prefs
-include: ${includes}/jdt.bnd, ${includes}/${api-layer}.bnd

Export-Package: ${p}.*; -split-package:=first

-buildpath = \
    ${osgi.annotation.buildpath}, \
    org.osgi.framework;maven-scope=provided;version=${framework-version}
```

| Param | Type | Example | Description |
|---|---|---|---|
| api-layer | string | `core` | Include layer selecting API level: core, cmpn, or companion |
| framework-version | version | `1.8` | org.osgi.framework package version the API compiles against |

## 2. `impl-bundle-bnd` — Reference implementation project bnd.bnd

```properties
# Set javac settings from JDT prefs
-include: ${includes}/jdt.bnd, ${includes}/cmpn.bnd

Bundle-Activator			= ${p}.Activator
Bundle-Description			= ${description}

Export-Service				= ${service-interface}

-privatepackage 			= ${p}.*

-buildpath = \
	${api-project};version=latest, \
	org.osgi.framework;maven-scope=provided;version=1.8
```

| Param | Type | Example | Description |
|---|---|---|---|
| description | string | `OSGi Preferences Service Reference Implementation` | Human-readable bundle description |
| service-interface | fqcn | `org.osgi.service.prefs.PreferencesService` | Spec service interface the bundle registers |
| api-project | bsn | `org.osgi.service.prefs` | BSN of the sibling API project |

## 3. `impl-activator` — RI BundleActivator with ServiceFactory

```java
package ${impl-package};

import java.util.Dictionary;
import java.util.Hashtable;

import org.osgi.framework.Bundle;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceFactory;
import org.osgi.framework.ServiceRegistration;
import ${service-interface};

public class Activator
		implements BundleActivator, ServiceFactory<${service-type}> {
	private static final String	SERVICE_NAME = "${service-interface}";
	private BundleContext		bundleContext = null;

	@Override
	public synchronized void start(BundleContext context) {
		this.bundleContext = context;
		Dictionary<String,Object> properties = new Hashtable<>(4);
		properties.put("Description", "${service-description}");
		context.registerService(SERVICE_NAME, this, properties);
	}

	@Override
	public synchronized void stop(BundleContext context) {
		// registration is unregistered automatically on bundle stop
	}

	@Override
	public ${service-type} getService(Bundle bundle,
			ServiceRegistration<${service-type}> registration) {
		return /* per-bundle scoped instance */ null;
	}

	@Override
	public void ungetService(Bundle bundle,
			ServiceRegistration<${service-type}> registration,
			${service-type} service) {
		// release per-bundle resources
	}
}
```

| Param | Type | Example | Description |
|---|---|---|---|
| impl-package | package | `org.osgi.impl.service.prefs` | Implementation package (== BSN) |
| service-interface | fqcn | `org.osgi.service.prefs.PreferencesService` | Service interface for import and registration name |
| service-type | class | `PreferencesService` | Simple name of the service type parameter |
| service-description | string | `The OSGi Preferences Service` | Description service property value |

## 4. `api-package-info` — Versioned API package-info.java

```java
/**
 * ${spec-name} Package Version ${package-version}.
 * <p>
 * Bundles wishing to use this package must list the package in the
 * Import-Package header of the bundle's manifest. This package has two types of
 * users: the consumers that use the API in this package and the providers that
 * implement the API in this package.
 * <p>
 * Example import for consumers using the API in this package:
 * <p>
 * {@code  Import-Package: ${package-name}; version="[${package-version},${next-major})"}
 * <p>
 * Example import for providers implementing the API in this package:
 * <p>
 * {@code  Import-Package: ${package-name}; version="[${package-version},${next-minor})"}
 */
@Version("${package-version}")
package ${package-name};

import org.osgi.annotation.versioning.Version;
```

| Param | Type | Example | Description |
|---|---|---|---|
| spec-name | string | `Log Service` | Specification display name |
| package-name | package | `org.osgi.service.log` | Exported package name |
| package-version | version | `1.5` | Semantic package version (major.minor, no micro) |
| next-major | version | `2.0` | Upper bound for consumers |
| next-minor | version | `1.6` | Upper bound for providers |

## 5. `tck-project-bnd` — TCK project bnd.bnd

```properties
# Set javac settings from JDT prefs
-include: ${includes}/jdt.bnd, ${includes}/osgi.tck.junit-platform.bnd, ${includes}/tck.bnd, ${includes}/cmpn.bnd

Bundle-Description					: A test case for the ${spec-name} implementation.

-conditionalpackage					= org.osgi.test.support.*
-privatepackage						=  \
	${p}.junit
Import-Package: ${-signaturetest}, *

-includeresource					= \
	tb1.jar

-signaturetest                      = ${api-package}

-buildpath = \
    org.osgi.test.support;version=project, \
    org.osgi.framework;maven-scope=provided;version=1.8, \
    ${api-project};version=latest

-runbundles = \
	${impl-project}; version=latest
```

| Param | Type | Example | Description |
|---|---|---|---|
| spec-name | string | `event generic mechanism` | Specification under test |
| api-package | package | `org.osgi.service.event` | API package for signature verification |
| api-project | bsn | `org.osgi.service.event` | API project BSN on the buildpath |
| impl-project | bsn | `org.osgi.impl.service.event` | RI BSN launched by the TCK run |

## 6. `tck-testcase` — TCK test class on OSGiTestCase

```java
package ${tck-package}.junit;

import org.osgi.test.support.OSGiTestCase;

public class ${test-class} extends OSGiTestCase {

	public void test${scenario}() throws Exception {
		// arrange: obtain service/API objects, use getContext() for BundleContext
		// act + assert: exhaustive legal/illegal input matrix per spec section ${spec-section}
	}
}
```

| Param | Type | Example | Description |
|---|---|---|---|
| tck-package | package | `org.osgi.test.cases.event` | TCK project package (== BSN) |
| test-class | class | `EventTests` | Test class name |
| scenario | identifier | `IllegalTopics` | Scenario suffix for the test method |
| spec-section | string | `113.3.2` | Specification section the test asserts |
