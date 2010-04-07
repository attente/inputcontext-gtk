/*
 * Copyright (C) 2010, Intel Corporation.
 *
 * Author: Raymond Liu <raymond.liu@intel.com>
 * 
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2.1 as published by the Free Software Foundation.
 * 
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA
 */

#include "debug.h"
#include <QEvent>
#include <QKeyEvent>

#include "qt-keysym-map.h"
#include "qt-gtk-translate.h"

GdkEventKey *
qt_key_event_to_gdk(int type, int key, int modifiers, char *text, GdkWindow *window)
{
	GdkEventKey *event = NULL;

	STEP();
	if ((type != QEvent::KeyPress) && (type != QEvent::KeyRelease))
		return NULL;

	if (type == QEvent::KeyPress) {
		event = (GdkEventKey *)(gdk_event_new(GDK_KEY_PRESS));
	} else {
		event = (GdkEventKey *)(gdk_event_new(GDK_KEY_RELEASE));
		event->state = GDK_RELEASE_MASK;
	}

	event->length = 0;
	event->string = 0;
	event->is_modifier = 0;
	event->time = GDK_CURRENT_TIME;

	if (modifiers & Qt::ShiftModifier)
		event->state |= GDK_SHIFT_MASK;
	if (modifiers & Qt::ControlModifier)
		event->state |= GDK_CONTROL_MASK;
	if (modifiers & Qt::AltModifier)
		event->state |= GDK_MOD1_MASK;

	event->keyval = QtKeyToXKeySym(key);

	event->window = window;

	if (event->window) {
		GdkKeymap *key_map = gdk_keymap_get_default();
		GdkKeymapKey *keys;
		gint n;

		g_object_ref(event->window); // seems when event is freed, the event->window will be unref

		if (gdk_keymap_get_entries_for_keyval(key_map, event->keyval, &keys, &n)) {
			event->hardware_keycode = keys[0].keycode;
			event->group = keys[0].group;
		} else {
			event->hardware_keycode = 0;
			event->group = 0;
		}
	}

	DBG("event type=%x, state=%x, keyval=%x, keycode=%x, group=%d",
		event->type, event->state, event->keyval, event->hardware_keycode, event->group);

	return event;
}

