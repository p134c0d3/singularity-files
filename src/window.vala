using Gtk;
using GLib;
using Singularity;
using Singularity.Widgets;
using Singularity.FileSystem;

namespace Singularity.Apps {

    [GtkTemplate(ui = "/dev/sinty/files/ui/main.ui")]
    public class FilesWindow : Singularity.Widgets.Window {
        [GtkChild] public unowned Box            files_ui_root;
        [GtkChild] public unowned ScrolledWindow content_scroll;
        [GtkChild] public unowned ScrolledWindow sidebar_scroll;
        [GtkChild] public unowned Box            places_box;

        public FilesWindow(Gtk.Application app) {
            Object(application: app);
        }
    }
}
