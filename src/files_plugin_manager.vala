using Peas;
using Gee;

namespace Singularity.Apps {

    public class FilesPluginManager : Object {
        private static FilesPluginManager? _instance = null;
        private Peas.Engine? engine = null;
        private GLib.Settings? settings = null;
        private Singularity.FilesPluginContext context;
        private Gee.ArrayList<Singularity.FileIconProvider> icon_providers
            = new Gee.ArrayList<Singularity.FileIconProvider>();
        private Gee.HashMap<string, Singularity.FilesPlugin> loaded
            = new Gee.HashMap<string, Singularity.FilesPlugin>();

        public static FilesPluginManager get_default() {
            if (_instance == null) _instance = new FilesPluginManager();
            return _instance;
        }

        private FilesPluginManager() {
            context = new Singularity.FilesPluginContext();
            context.file_icon_provider_added.connect((p) => {
                if (!icon_providers.contains(p)) icon_providers.add(p);
            });
            context.file_icon_provider_removed.connect((p) => {
                icon_providers.remove(p);
            });

            var src = GLib.SettingsSchemaSource.get_default();
            if (src != null && src.lookup("dev.sinty.desktop", true) != null) {
                settings = new GLib.Settings("dev.sinty.desktop");
            }

            load();
        }

        private void load() {
            engine = Peas.Engine.get_default();

            string[] plugin_dirs = {};
            string? env_path = Environment.get_variable("SINGULARITY_PLUGIN_PATH");
            if (env_path != null) {
                foreach (string p in env_path.split(":")) plugin_dirs += p;
            }
            try {
                string exe = GLib.FileUtils.read_link("/proc/self/exe");
                string prefix = GLib.Path.get_dirname(GLib.Path.get_dirname(exe));
                plugin_dirs += GLib.Path.build_filename(prefix, "share", "singularity", "plugins");
                foreach (string libdir in new string[] {
                        "lib", "lib64",
                        "lib/x86_64-linux-gnu", "lib/aarch64-linux-gnu" }) {
                    plugin_dirs += GLib.Path.build_filename(prefix, libdir, "singularity", "plugins");
                }
            } catch (Error e) { }
            plugin_dirs += GLib.Path.build_filename(Environment.get_user_data_dir(), "singularity", "plugins");
            foreach (unowned string d in Environment.get_system_data_dirs())
                plugin_dirs += GLib.Path.build_filename(d, "singularity", "plugins");
            foreach (string p in plugin_dirs)
                engine.add_search_path(p, p);

            engine.rescan_plugins();

            string[] enabled = (settings != null)
                ? settings.get_strv("enabled-plugins") : new string[0];

            var model = (GLib.ListModel) engine;
            uint n = model.get_n_items();
            for (uint i = 0; i < n; i++) {
                var info = (Peas.PluginInfo) model.get_item(i);
                string module = info.get_module_name();
                bool want = false;
                foreach (string s in enabled) {
                    if (s == module) { want = true; break; }
                }
                if (!want) continue;
                try {
                    if (!info.is_loaded()) engine.load_plugin(info);
                    string[] names = {};
                    Value[] values = {};
                    var ext = engine.create_extension_with_properties(
                        info, typeof(Singularity.FilesPlugin), names, values);
                    if (ext != null && ext is Singularity.FilesPlugin) {
                        var plugin = (Singularity.FilesPlugin) ext;
                        plugin.activate(context);
                        loaded.set(module, plugin);
                    }
                } catch (Error e) {
                    warning("Files plugin %s failed to load: %s", module, e.message);
                }
            }
        }

        public bool has_icon_providers() {
            return icon_providers.size > 0;
        }

        public Singularity.FileIconProvider? provider_for(GLib.File file, string? content_type) {
            foreach (var p in icon_providers) {
                if (p.matches(file, content_type)) return p;
            }
            return null;
        }
    }
}
