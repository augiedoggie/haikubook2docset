-- Manual fixes for the docset index

BEGIN TRANSACTION;


-- fix Guide pages
UPDATE searchIndex SET type = 'Guide', name = 'AppKit Introduction' WHERE name = 'app_intro';
UPDATE searchIndex SET type = 'Guide', name = 'Launch Daemon Introduction' WHERE name = 'launch_intro';
UPDATE searchIndex SET type = 'Guide', name = 'Layout API Introduction' WHERE name = 'layout_intro';
UPDATE searchIndex SET type = 'Guide', name = 'LocaleKit Introduction' WHERE name = 'locale_intro';
UPDATE searchIndex SET type = 'Guide', name = 'MIDI2Kit Introduction' WHERE name = 'midi2_intro';
UPDATE searchIndex SET type = 'Guide', name = 'NetworkKit Introduction' WHERE name = 'network_intro';
UPDATE searchIndex SET type = 'Guide', name = 'StorageKit Introduction' WHERE name = 'storage_intro';
UPDATE searchIndex SET type = 'Guide', name = 'SupportKit Introduction' WHERE name = 'support_intro';
UPDATE searchIndex SET type = 'Guide', name = 'Documenting the API' WHERE name = 'apidoc';
UPDATE searchIndex SET type = 'Guide', name = 'Password and Key Storage API' WHERE name = 'app_keystore';
UPDATE searchIndex SET type = 'Guide', name = 'Messaging Foundations' WHERE name = 'app_messaging';
UPDATE searchIndex SET type = 'Guide', name = 'Application Level API Incompatibilities with BeOS' WHERE name = 'compatibility';
UPDATE searchIndex SET type = 'Guide', name = 'Credits' WHERE name = 'credits';
UPDATE searchIndex SET type = 'Guide', name = 'File System Modules' WHERE name = 'fs_modules';
UPDATE searchIndex SET type = 'Guide', name = 'Writing drivers for USB devices' WHERE name = 'usb_modules';
UPDATE searchIndex SET type = 'Guide', name = 'Layout API tips' WHERE name = 'layout_tips';
UPDATE searchIndex SET type = 'Guide', name = 'Keyboard' WHERE name = 'keyboard';
UPDATE searchIndex SET type = 'Guide', name = 'Drivers' WHERE name = 'drivers' AND path = 'drivers.html#';
UPDATE searchIndex SET type = 'Guide', name = 'The old Midi Kit (libmidi.so)' WHERE name = 'midi1' AND path = 'midi1.html#';
UPDATE searchIndex SET type = 'Guide', name = 'C, POSIX, GNU and BSD functions' WHERE name = 'libroot' AND path = 'libroot.html#';
UPDATE searchIndex SET type = 'Guide', name = 'Json Handling' WHERE name = 'json' AND path = 'json.html#';


-- fix Category pages
UPDATE searchIndex SET type = 'Category', name = 'Application Kit' WHERE name = 'app';
UPDATE searchIndex SET type = 'Category', name = 'Game Kit' WHERE name = 'game';
UPDATE searchIndex SET type = 'Category', name = 'Interface Kit' WHERE name = 'interface' and type = 'Data';
UPDATE searchIndex SET type = 'Category', name = 'Locale Kit' WHERE name = 'locale';
UPDATE searchIndex SET type = 'Category', name = 'Mail Kit' WHERE name = 'mail';
UPDATE searchIndex SET type = 'Category', name = 'Media Kit' WHERE name = 'media';
UPDATE searchIndex SET type = 'Category', name = 'MIDI2 Kit' WHERE name = 'midi2';
UPDATE searchIndex SET type = 'Category', name = 'Network Kit' WHERE name = 'network';
UPDATE searchIndex SET type = 'Category', name = 'Storage Kit' WHERE name = 'storage';
UPDATE searchIndex SET type = 'Category', name = 'Support Kit' WHERE name = 'support';
UPDATE searchIndex SET type = 'Category', name = 'Translation Kit' WHERE name = 'translation';
UPDATE searchIndex SET type = 'Category', name = 'Global functions' WHERE name = 'support_globals';
UPDATE searchIndex SET type = 'Category', name = 'Layout API' WHERE name = 'layout' and type = 'Data';
UPDATE searchIndex SET type = 'Category', name = 'Experimental Network Services Support' WHERE name = 'netservices';
UPDATE searchIndex SET type = 'Category', name = 'Device Drivers' WHERE name = 'drivers' AND path = 'group__drivers.html#';
UPDATE searchIndex SET type = 'Category', name = 'The old Midi Kit (libmidi.so)' WHERE name = 'midi1' AND path = 'group__midi1.html#';
UPDATE searchIndex SET type = 'Category', name = 'C, POSIX, GNU and BSD functions' WHERE name = 'libroot' AND path = 'group__libroot.html#';
UPDATE searchIndex SET type = 'Category', name = 'Json Handling' WHERE name = 'json' AND path = 'group__json.html#';
UPDATE searchIndex SET type = 'Category', name = 'libtranslation' WHERE name = 'libtranslation';
UPDATE searchIndex SET type = 'Category', name = 'libbe' WHERE name = 'libbe';


-- Enum cleanup
UPDATE searchIndex SET type = 'Enum' WHERE type = 'Data' AND path like '%\_8h%' ESCAPE '\';
UPDATE searchIndex SET type = 'Enum', name = 'BPrivate::Network::BNetworkRequestError::ErrorType' WHERE name = 'ErrorType';
UPDATE searchIndex SET type = 'Enum', name = 'BPrivate::Network::BHttpMethod::Verb' WHERE name = 'Verb';


COMMIT;
