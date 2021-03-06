TOP_DIR = ..

include($$TOP_DIR/config.pri)

TEMPLATE = lib
TARGET = $$TOP_DIR/lib/$$MALIIT_CONNECTION_GLIB_LIB
CONFIG += staticlib

CONFIG += link_pkgconfig
PKGCONFIG += glib-2.0 gthread-2.0 dbus-glib-1

system(pkg-config gio-2.0 --atleast-version 2.26) {
    DEFINES   += MALIIT_USE_GIO_API
    PKGCONFIG += gio-2.0
}

debug{
    DEFINES += ENABLE_DEBUG
}

!enable-dbus-activation {
    DEFINES += NO_DBUS_ACTIVATION
}

DEFINES += G_LOG_DOMAIN=\\\"Maliit\\\"

# Generated dbus glue code has warnings of this type, so disable them
QMAKE_CFLAGS_DEBUG += -Wno-unused-parameter
QMAKE_CFLAGS_RELEASE += -Wno-unused-parameter

HEADERS += \
    meego-im-proxy.h \
    meego-imcontext-dbus.h \
    meego-im-connector.h \
    qt-keysym-map.h \
    debug.h \
    meego-imcontext-dbus-private.h \
    meego-im-connector-private.h \

SOURCES += \
    meego-im-proxy.c \
    meego-imcontext-dbus.c \
    meego-im-connector.c \
    qt-keysym-map.cpp \
    debug.c \

include($$TOP_DIR/dbus_interfaces/dbus_interfaces.pri)

# improxy
# Generate dbus glue
QMAKE_EXTRA_TARGETS += dbus_glue_improxy
dbus_glue_improxy.target = $$OUT_PWD/meego-im-proxy-glue.h
dbus_glue_improxy.output = $$OUT_PWD/meego-im-proxy-glue.h
dbus_glue_improxy.depends = $$DBUS_SERVER_XML
dbus_glue_improxy.commands = \
    dbus-binding-tool --prefix=meego_im_proxy --mode=glib-client \
        --output=$$OUT_PWD/meego-im-proxy-glue.h \
        $$DBUS_SERVER_XML

# Use to work around the fact that qmake looks up the target for the generated header wrong
QMAKE_EXTRA_TARGETS += fake_dbus_glue_improxy
fake_dbus_glue_improxy.target = meego-im-proxy-glue.h
fake_dbus_glue_improxy.depends = dbus_glue_improxy

# imcontext
# Generate dbus glue
QMAKE_EXTRA_TARGETS += dbus_glue_imcontext
dbus_glue_imcontext.target = $$OUT_PWD/meego-imcontext-dbus-glue.h
dbus_glue_imcontext.output = $$OUT_PWD/meego-imcontext-dbus-glue.h
dbus_glue_imcontext.depends = $$DBUS_CONTEXT_XML
dbus_glue_imcontext.commands = \
    dbus-binding-tool --prefix=meego_imcontext_dbus --mode=glib-server \
        --output=$$OUT_PWD/meego-imcontext-dbus-glue.h \
        $$DBUS_CONTEXT_XML

# Use to work around the fact that qmake looks up the target for the generated header wrong
QMAKE_EXTRA_TARGETS += fake_dbus_glue_imcontext
fake_dbus_glue_imcontext.target = meego-imcontext-dbus-glue.h
fake_dbus_glue_imcontext.depends = dbus_glue_imcontext

GLIB_GENMARSHAL_LIST += maliitmarshalers.list

OTHER_FILES += maliitmarshalers.list

glib_genmarshal_header.name = glib-genmarshal header ${QMAKE_FILE_IN}
glib_genmarshal_header.commands = glib-genmarshal --prefix=_maliit_marshal --header --g-fatal-warnings ${QMAKE_FILE_IN} > ${QMAKE_FILE_OUT}
glib_genmarshal_header.output = ${QMAKE_FILE_IN_BASE}.h
glib_genmarshal_header.variable_out = HEADERS
glib_genmarshal_header.input = GLIB_GENMARSHAL_LIST

glib_genmarshal_source.name = glib-genmarshal source ${QMAKE_FILE_IN}
glib_genmarshal_source.commands = glib-genmarshal --prefix=_maliit_marshal --body --g-fatal-warnings ${QMAKE_FILE_IN} > ${QMAKE_FILE_OUT}
glib_genmarshal_source.output = ${QMAKE_FILE_IN_BASE}.c
glib_genmarshal_source.variable_out = SOURCES
glib_genmarshal_source.input = GLIB_GENMARSHAL_LIST

QMAKE_EXTRA_COMPILERS += glib_genmarshal_header glib_genmarshal_source
