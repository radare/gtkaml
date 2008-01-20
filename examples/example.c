main(){}
/*#include "example.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct _MyWidgetPrivate {
	GtkLabel* label5;
	GtkNotebook* notebook1;
	GtkLabel* label4;
	GtkLabel* label2;
	GtkCheckButton* check_button;
	GtkHBox* hbox1;
	GtkHButtonBox* hbuttonbox1;
	GtkButton* abort;
	GtkButton* button2;
	GtkButton* fail;
};
#define MY_WIDGET_GET_PRIVATE(o) (G_TYPE_INSTANCE_GET_PRIVATE ((o), TYPE_MY_WIDGET, MyWidgetPrivate))
enum  {
	MY_WIDGET_DUMMY_PROPERTY
};
static void my_widget_on_click (MyWidget* self);
static void __lambda0 (GtkButton* target, MyWidget* self);
static GObject * my_widget_constructor (GType type, guint n_construct_properties, GObjectConstructParam * construct_properties);
static gpointer my_widget_parent_class = NULL;
static void my_widget_dispose (GObject * obj);


static void my_widget_on_click (MyWidget* self) {
	g_return_if_fail (IS_MY_WIDGET (self));
	fprintf (stdout, "you clicked me!");
}


MyWidget* my_widget_new (void) {
	MyWidget * self;
	self = g_object_newv (TYPE_MY_WIDGET, 0, NULL);
	return self;
}


static void __lambda0 (GtkButton* target, MyWidget* self) {
	g_return_if_fail (target == NULL || GTK_IS_BUTTON (target));
	my_widget_on_click (self);
}


static GObject * my_widget_constructor (GType type, guint n_construct_properties, GObjectConstructParam * construct_properties) {
	GObject * obj;
	MyWidgetClass * klass;
	GObjectClass * parent_class;
	MyWidget * self;
	klass = MY_WIDGET_CLASS (g_type_class_peek (TYPE_MY_WIDGET));
	parent_class = G_OBJECT_CLASS (g_type_class_peek_parent (klass));
	obj = parent_class->constructor (type, n_construct_properties, construct_properties);
	self = MY_WIDGET (obj);
	{
		GtkLabel* _tmp0;
		GtkNotebook* _tmp1;
		GtkLabel* _tmp2;
		GtkLabel* _tmp3;
		GtkHBox* _tmp4;
		GtkCheckButton* _tmp5;
		GtkHButtonBox* _tmp6;
		GtkButton* _tmp7;
		gboolean _tmp8;
		GtkButton* _tmp9;
		gboolean _tmp10;
		GtkButton* _tmp11;
		gboolean _tmp12;
		_tmp0 = NULL;
		self->priv->label5 = (_tmp0 = g_object_ref_sink (gtk_label_new ("<b>Dialog Box Title Here</b>")), (self->priv->label5 == NULL ? NULL : (self->priv->label5 = (g_object_unref (self->priv->label5), NULL))), _tmp0);
		gtk_label_set_use_markup (self->priv->label5, TRUE);
		gtk_box_pack_start (GTK_BOX (self), GTK_WIDGET (self->priv->label5), FALSE, FALSE, 0);
		_tmp1 = NULL;
		self->priv->notebook1 = (_tmp1 = g_object_ref_sink (gtk_notebook_new ()), (self->priv->notebook1 == NULL ? NULL : (self->priv->notebook1 = (g_object_unref (self->priv->notebook1), NULL))), _tmp1);
		gtk_box_pack_start (GTK_BOX (self), GTK_WIDGET (self->priv->notebook1), TRUE, TRUE, 0);
		_tmp2 = NULL;
		self->priv->label4 = (_tmp2 = g_object_ref_sink (gtk_label_new ("label\nmultiline")), (self->priv->label4 == NULL ? NULL : (self->priv->label4 = (g_object_unref (self->priv->label4), NULL))), _tmp2);
		gtk_container_add (GTK_CONTAINER (self->priv->notebook1), GTK_WIDGET (self->priv->label4));
		_tmp3 = NULL;
		self->priv->label2 = (_tmp3 = g_object_ref_sink (gtk_label_new ("Page 1")), (self->priv->label2 == NULL ? NULL : (self->priv->label2 = (g_object_unref (self->priv->label2), NULL))), _tmp3);
		gtk_notebook_set_tab_label (self->priv->notebook1, gtk_notebook_get_nth_page (self->priv->notebook1, 0), GTK_WIDGET (self->priv->label2));
		_tmp4 = NULL;
		self->priv->hbox1 = (_tmp4 = g_object_ref_sink (gtk_hbox_new (FALSE, 0)), (self->priv->hbox1 == NULL ? NULL : (self->priv->hbox1 = (g_object_unref (self->priv->hbox1), NULL))), _tmp4);
		gtk_container_add (GTK_CONTAINER (self->priv->notebook1), GTK_WIDGET (self->priv->hbox1));
		_tmp5 = NULL;
		self->priv->check_button = (_tmp5 = g_object_ref_sink (gtk_check_button_new_with_label ("check button")), (self->priv->check_button == NULL ? NULL : (self->priv->check_button = (g_object_unref (self->priv->check_button), NULL))), _tmp5);
		gtk_toggle_button_set_active (GTK_TOGGLE_BUTTON (self->priv->check_button), TRUE);
		gtk_notebook_set_tab_label (self->priv->notebook1, gtk_notebook_get_nth_page (self->priv->notebook1, 1), GTK_WIDGET (self->priv->check_button));
		_tmp6 = NULL;
		self->priv->hbuttonbox1 = (_tmp6 = g_object_ref_sink (gtk_hbutton_box_new ()), (self->priv->hbuttonbox1 == NULL ? NULL : (self->priv->hbuttonbox1 = (g_object_unref (self->priv->hbuttonbox1), NULL))), _tmp6);
		gtk_box_pack_start (GTK_BOX (self), GTK_WIDGET (self->priv->hbuttonbox1), FALSE, TRUE, 0);
		_tmp7 = NULL;
		self->priv->abort = (_tmp7 = g_object_ref_sink (gtk_button_new_with_mnemonic ("_abort")), (self->priv->abort == NULL ? NULL : (self->priv->abort = (g_object_unref (self->priv->abort), NULL))), _tmp7);
		g_object_set (GTK_WIDGET (self->priv->abort), "can-default", TRUE, NULL);
		g_signal_connect_object (self->priv->abort, "clicked", ((GCallback) __lambda0), self, 0);
		gtk_container_add (GTK_CONTAINER (self->priv->hbuttonbox1), GTK_WIDGET (self->priv->abort));
		_tmp9 = NULL;
		self->priv->button2 = (_tmp9 = g_object_ref_sink (gtk_button_new_from_stock ("gtk-redo")), (self->priv->button2 == NULL ? NULL : (self->priv->button2 = (g_object_unref (self->priv->button2), NULL))), _tmp9);
		g_object_set (GTK_WIDGET (self->priv->button2), "can-default", TRUE, NULL);
		gtk_container_add (GTK_CONTAINER (self->priv->hbuttonbox1), GTK_WIDGET (self->priv->button2));
		_tmp11 = NULL;
		self->priv->fail = (_tmp11 = g_object_ref_sink (gtk_button_new_with_mnemonic ("fail")), (self->priv->fail == NULL ? NULL : (self->priv->fail = (g_object_unref (self->priv->fail), NULL))), _tmp11);
		g_object_set (GTK_WIDGET (self->priv->fail), "can-default", TRUE, NULL);
		gtk_container_add (GTK_CONTAINER (self->priv->hbuttonbox1), GTK_WIDGET (self->priv->fail));
	}
	return obj;
}


static void my_widget_class_init (MyWidgetClass * klass) {
	my_widget_parent_class = g_type_class_peek_parent (klass);
	g_type_class_add_private (klass, sizeof (MyWidgetPrivate));
	G_OBJECT_CLASS (klass)->constructor = my_widget_constructor;
	G_OBJECT_CLASS (klass)->dispose = my_widget_dispose;
}


static void my_widget_init (MyWidget * self) {
	self->priv = MY_WIDGET_GET_PRIVATE (self);
}


static void my_widget_dispose (GObject * obj) {
	MyWidget * self;
	self = MY_WIDGET (obj);
	(self->priv->label5 == NULL ? NULL : (self->priv->label5 = (g_object_unref (self->priv->label5), NULL)));
	(self->priv->notebook1 == NULL ? NULL : (self->priv->notebook1 = (g_object_unref (self->priv->notebook1), NULL)));
	(self->priv->label4 == NULL ? NULL : (self->priv->label4 = (g_object_unref (self->priv->label4), NULL)));
	(self->priv->label2 == NULL ? NULL : (self->priv->label2 = (g_object_unref (self->priv->label2), NULL)));
	(self->priv->check_button == NULL ? NULL : (self->priv->check_button = (g_object_unref (self->priv->check_button), NULL)));
	(self->priv->hbox1 == NULL ? NULL : (self->priv->hbox1 = (g_object_unref (self->priv->hbox1), NULL)));
	(self->priv->hbuttonbox1 == NULL ? NULL : (self->priv->hbuttonbox1 = (g_object_unref (self->priv->hbuttonbox1), NULL)));
	(self->priv->abort == NULL ? NULL : (self->priv->abort = (g_object_unref (self->priv->abort), NULL)));
	(self->priv->button2 == NULL ? NULL : (self->priv->button2 = (g_object_unref (self->priv->button2), NULL)));
	(self->priv->fail == NULL ? NULL : (self->priv->fail = (g_object_unref (self->priv->fail), NULL)));
	G_OBJECT_CLASS (my_widget_parent_class)->dispose (obj);
}


GType my_widget_get_type (void) {
	static GType my_widget_type_id = 0;
	if (G_UNLIKELY (my_widget_type_id == 0)) {
		static const GTypeInfo g_define_type_info = { sizeof (MyWidgetClass), (GBaseInitFunc) NULL, (GBaseFinalizeFunc) NULL, (GClassInitFunc) my_widget_class_init, (GClassFinalizeFunc) NULL, NULL, sizeof (MyWidget), 0, (GInstanceInitFunc) my_widget_init };
		my_widget_type_id = g_type_register_static (GTK_TYPE_VBOX, "MyWidget", &g_define_type_info, 0);
	}
	return my_widget_type_id;
}
*/



