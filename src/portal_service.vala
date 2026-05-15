using GLib;

namespace Singularity.Apps {

    [DBus (name = "org.freedesktop.impl.portal.FileChooser")]
    public class PortalService : Object {
        private FilesApp app;

        public PortalService(FilesApp app) {
            this.app = app;
        }

        public async void open_file(string handle, string app_id, string parent_window, string title, HashTable<string, Variant> options, out uint response, out HashTable<string, Variant> results) throws Error {
            // TODO: Implement full portal flow
            response = 1;
            results = new HashTable<string, Variant>(str_hash, str_equal);
        }

        public async void save_file(string handle, string app_id, string parent_window, string title, HashTable<string, Variant> options, out uint response, out HashTable<string, Variant> results) throws Error {
            // TODO: Implement full portal flow
            response = 1;
            results = new HashTable<string, Variant>(str_hash, str_equal);
        }
    }
}
