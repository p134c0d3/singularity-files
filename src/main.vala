using Gtk;
using GLib;
using Singularity;

namespace Singularity.Apps {

    public static int main(string[] args) {
        // Use a unique app ID in portal mode to avoid connecting to an existing instance.
        string app_id = "dev.sinty.files";
        foreach (var arg in args) {
            if (arg == "--portal-mode") {
                app_id = "dev.sinty.files.portal.%lld".printf(GLib.get_real_time());
                break;
            }
        }

        var app = new FilesApp(app_id);
        return app.run(args);
    }
}
