/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.eclipse.xtext.tasks

import java.util.List
import org.junit.Before
import org.junit.Test

import static org.eclipse.xtext.tasks.TaskAssert.*
import static org.junit.Assert.*

/**
 * @author Stefan Oehme - Initial contribution and API
 */
class DefaultTaskParserTest {
	ITaskParser parser
	TaskTags definitions

	@Before
	def void setup() {
		parser = new DefaultTaskParser
		definitions = new DefaultTaskTagProvider().getTaskTags(null)
	}

	@Test
	def void testCaseInSensitive() {
		definitions.caseSensitive = false
		'''
			/*
			 * FixMe case insensitve match
			 */
		'''.assertContainsTasks(
			#[
				new Task() => [
					tag = new TaskTag => [
						name = "FIXME"
						priority = Priority.HIGH
					]
					description = " case insensitve match"
					lineNumber = 2
					offset = 7
				]
			]
		)
	}

	@Test
	def void testCaseSensitve() {
		'''
			/* TODO this is a task
			 * FIXME this cannot work
			 * XXX: god, this is bad
			 * TODO
			 * FixMe this should not match
			 */
		'''.assertContainsTasks(
			#[
				new Task() => [
					tag = new TaskTag => [
						name = "TODO"
						priority = Priority.NORMAL
					]
					description = " this is a task"
					lineNumber = 1
					offset = 3
				],
				new Task() => [
					tag = new TaskTag => [
						name = "FIXME"
						priority = Priority.HIGH
					]
					description = " this cannot work"
					lineNumber = 2
					offset = 27
				],
				new Task() => [
					tag = new TaskTag => [
						name = "XXX"
						priority = Priority.NORMAL
					]
					description = ": god, this is bad"
					lineNumber = 3
					offset = 54
				],
				new Task() => [
					tag = new TaskTag => [
						name = "TODO"
						priority = Priority.NORMAL
					]
					description = ""
					lineNumber = 4
					offset = 80
				]
			])
	}

	private def assertContainsTasks(CharSequence source, List<Task> expectedTasks) {
		val actualTasks = parser.parseTasks(source.toString, definitions)
		assertEquals(expectedTasks.size, actualTasks.size)
		for (i : 0 ..< expectedTasks.size) {
			assertExactMatch(expectedTasks.get(i), actualTasks.get(i))
		}
	}
}
