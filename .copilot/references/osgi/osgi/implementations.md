---
layout: default
title: osgi — canonical implementations
nav_exclude: true
---

<!-- Generated from implementations.json — do not hand-edit -->

# Canonical Implementations: osgi (osgi/osgi)

All excerpts pinned to commit `8c7184da`.

## spec-api-impl-tck-triple

### PRIMARY: org.osgi.impl.service.prefs/bnd.bnd (L1-14) — complete RI project

[permalink](https://github.com/osgi/osgi/blob/8c7184dad43779668052afe5b29a2a201e527b52/org.osgi.impl.service.prefs/bnd.bnd#L1-L14)

```properties
# Set javac settings from JDT prefs
-include: ${includes}/jdt.bnd, ${includes}/cmpn.bnd

Bundle-Activator			= ${p}.Activator
Bundle-Description			= OSGi Preferences Service Reference Implementation by Sun Microsystems.
Bundle-Vendor				= Sun Microsystems, Inc.

Export-Service				= org.osgi.service.prefs.PreferencesService

-privatepackage 			= ${p}.*

-buildpath = \
	org.osgi.service.prefs;version=latest, \
	org.osgi.framework;maven-scope=provided;version=1.8
```

14 lines for a full RI: activator, Export-Service, private packages, API-project buildpath.

### org.osgi.service.log/bnd.bnd (L1-8) — API side of the triple

[permalink](https://github.com/osgi/osgi/blob/8c7184dad43779668052afe5b29a2a201e527b52/org.osgi.service.log/bnd.bnd#L1-L8)

```properties
# Set javac settings from JDT prefs
-include: ${includes}/jdt.bnd, ${includes}/companion.bnd, ${includes}/core.bnd

Export-Package: ${p}.*; -split-package:=first

-buildpath = \
    ${osgi.annotation.buildpath}, \
    org.osgi.framework;maven-scope=provided;version=1.8
```

## central-cnf-includes-config

### PRIMARY: cnf/build.bnd (L80-111) — global identity + reproducibility

[permalink](https://github.com/osgi/osgi/blob/8c7184dad43779668052afe5b29a2a201e527b52/cnf/build.bnd#L80-L111)

```properties
-groupid: org.osgi
-pom: version=${if;${def;-snapshot};${versionmask;===;${@version}}-${def;-snapshot};${versionmask;===s;${@version}}}
Bundle-Name: ${-groupid}:${bsn}
Bundle-Copyright: ${copyright}
Bundle-Vendor:    Eclipse Foundation
Bundle-Version:   ${build.version}-SNAPSHOT
Bundle-DocURL:    https://docs.osgi.org/
Git-Descriptor:   ${system-allow-fail;git describe --dirty --always --abbrev=9}
Git-SHA:          ${system-allow-fail;git rev-list -1 --no-abbrev-commit HEAD}
Bundle-SCM:       url=https://github.com/osgi/osgi, \
                  connection=scm:git:https://github.com/osgi/osgi.git, \
                  developerConnection=scm:git:git@github.com:osgi/osgi.git, \
                  tag=${Git-Descriptor}
Bundle-Developers: osgi; \
                  email=osgi-wg@eclipse.org; \
                  name="OSGi Working Group"; \
                  organization="Eclipse Foundation"; \
                  organizationUrl="https://www.osgi.org/"
SPDX-License-Identifier: Apache-2.0
Bundle-License: ${SPDX-License-Identifier};\
                description="This program and the accompanying materials are made available under the terms of the Apache License, Version 2.0.";\
                link="https://opensource.org/licenses/Apache-2.0"

-reproducible: true
-noextraheaders: true
-removeheaders: Private-Package
-includeresource.legal:\
 "META-INF/=${project.workspace}/LICENSE",\
 "META-INF/=${project.workspace}/NOTICE"

# Don't baseline Bundle-Version
-diffignore: Bundle-Version
```

### org.osgi.test.cases.event/bnd.bnd (L1-2) — include-layer composition

```properties
# Set javac settings from JDT prefs
-include: ${includes}/jdt.bnd, ${includes}/osgi.tck.junit-platform.bnd, ${includes}/tck.bnd, ${includes}/cmpn.bnd
```

## semantic-package-versioning

### PRIMARY: org.osgi.service.log/src/org/osgi/service/log/package-info.java (L19-40)

[permalink](https://github.com/osgi/osgi/blob/8c7184dad43779668052afe5b29a2a201e527b52/org.osgi.service.log/src/org/osgi/service/log/package-info.java#L19-L40)

```java
/**
 * Log Service Package Version 1.5.
 * <p>
 * Bundles wishing to use this package must list the package in the
 * Import-Package header of the bundle's manifest. This package has two types of
 * users: the consumers that use the API in this package and the providers that
 * implement the API in this package.
 * <p>
 * Example import for consumers using the API in this package:
 * <p>
 * {@code  Import-Package: org.osgi.service.log; version="[1.5,2.0)"}
 * <p>
 * Example import for providers implementing the API in this package:
 * <p>
 * {@code  Import-Package: org.osgi.service.log; version="[1.5,1.6)"}
 * 
 * @author $Id: ee98973025874319c4fcbc449e8d4b7b9a3d1321 $
 */
@Version("1.5")
package org.osgi.service.log;

import org.osgi.annotation.versioning.Version;
```

## tck-in-framework-junit

### PRIMARY: org.osgi.test.cases.event/bnd.bnd (L1-31) — complete TCK project

[permalink](https://github.com/osgi/osgi/blob/8c7184dad43779668052afe5b29a2a201e527b52/org.osgi.test.cases.event/bnd.bnd#L1-L31)

```properties
# Set javac settings from JDT prefs
-include: ${includes}/jdt.bnd, ${includes}/osgi.tck.junit-platform.bnd, ${includes}/tck.bnd, ${includes}/cmpn.bnd

Bundle-Description					: A test case for the event generic mechanism implementation.

-conditionalpackage					= org.osgi.test.support.*
-privatepackage						=  \
	${p}.junit
Export-Package						= \
	${p}.service
Import-Package: ${-signaturetest}, *

-includeresource					= \
	tb1.jar, \
	tb2.jar
	
-signaturetest                      = org.osgi.service.event

-buildpath = \
    org.osgi.test.support;version=project, \
    org.osgi.framework;maven-scope=provided;version=1.8,\
    org.osgi.resource;maven-scope=provided;version=1.0,\
    org.osgi.util.tracker;maven-scope=provided;version=1.5,\
    org.osgi.namespace.implementation;version=1.0, \
    org.osgi.namespace.service;version=1.0, \
    org.osgi.service.event;version=latest

-runbundles = \
	org.osgi.impl.service.cm; version=latest, \
	org.osgi.impl.service.event; version=latest, \
	org.osgi.impl.service.log; version=latest
```

### EventTests.java (L33-52) — TCK test style

[permalink](https://github.com/osgi/osgi/blob/8c7184dad43779668052afe5b29a2a201e527b52/org.osgi.test.cases.event/src/org/osgi/test/cases/event/junit/EventTests.java#L33-L52)

```java
public class EventTests extends OSGiTestCase {

	public void testIllegalTopics() {
		String[] illegalTopics = new String[] {"", "*", "/error_topic",
				"//error_topic1", "é/error_topic2", "topic/error_topic3/",
				"error_topic&", "topic//error-topic4", "topic\\error_topic5"};
		Hashtable<String,Object> properties = new Hashtable<>();
		// illegal topics tested
		for (int i = 0; i < illegalTopics.length; i++) {
			String topic = illegalTopics[i];
			try {
				new Event(topic, (Dictionary<String, ? >) properties);
				fail("Excepted IllegalArgumentException for topic:[" + topic
						+ "]");
			}
			catch (IllegalArgumentException e) {
				// expected
			}
		}
	}
```

### OSGiTestCase.java (L42-66) — support base class

[permalink](https://github.com/osgi/osgi/blob/8c7184dad43779668052afe5b29a2a201e527b52/org.osgi.test.support/src/org/osgi/test/support/OSGiTestCase.java#L42-L66)

```java
public abstract class OSGiTestCase extends TestCase {
	private volatile BundleContext context;

	/**
	 * This method is called by the JUnit runner for OSGi, and gives us a Bundle
	 * Context.
	 */
	public void setBundleContext(BundleContext context) {
		this.context = context;
	}

	/**
	 * Returns the current Bundle Context
	 */
	public BundleContext getContext() {
		BundleContext c = context;
		if (c == null) {
			Bundle b = FrameworkUtil.getBundle(getClass());
			if ( b != null )
				return context = b.getBundleContext();

			fail("No Bundle context set, are you running in OSGi Test mode?");
		}
		return c;
	}
```

## impl-activator-servicefactory

### PRIMARY: org.osgi.impl.service.prefs/.../Activator.java (L33-46)

[permalink](https://github.com/osgi/osgi/blob/8c7184dad43779668052afe5b29a2a201e527b52/org.osgi.impl.service.prefs/src/org/osgi/impl/service/prefs/Activator.java#L33-L46)

```java
public class Activator
		implements BundleActivator, ServiceFactory<PreferencesService> {
	private static final String	PREFERENCES_SERVICE	= "org.osgi.service.prefs.PreferencesService";
	private BundleContext		bundleContext		= null;

	@Override
	public synchronized void start(
			@SuppressWarnings("hiding") BundleContext bundleContext) {
		this.bundleContext = bundleContext;
		Dictionary<String,Object> properties = new Hashtable<>(4);
		properties.put("Description", "The OSGi Preferences Service");
		properties.put("BackingStore", "file");
		bundleContext.registerService(PREFERENCES_SERVICE, this, properties);
	}
```

## bsn-gradle-bnd-workspace

### PRIMARY: gradle.properties (L19-36)

[permalink](https://github.com/osgi/osgi/blob/8c7184dad43779668052afe5b29a2a201e527b52/gradle.properties#L19-L36)

```properties
# JVM args to run gradle
org.gradle.jvmargs=-Xms1g -Xmx3g

# cnf project name
bnd_cnf=cnf

# bnd_version is the version of the Bnd Gradle plugin
bnd_version=7.1.0

# The URLs to the repos for the Bnd Gradle plugin
bnd_snapshots=https://bndtools.jfrog.io/bndtools/libs-snapshot-local
bnd_releases=https://bndtools.jfrog.io/bndtools/libs-release-local

# bnd_build can be set to the name of a primary project whose dependencies will seed the set of projects to build.
bnd_build=osgi.build

# Default gradle task to build
bnd_defaultTask=assemble
```
