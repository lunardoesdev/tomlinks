package main

import "core:encoding/ini"
import "core:fmt"
import "core:log"
import "core:os"
import "core:strings"

SubCommand :: enum {
	Restore = 0,
	Collect,
	Help
}

Error :: enum {
	None = 0,
	Some
}

sync :: proc(src: string, dest: string) -> (ok: bool) {
	log.info("syncing from", src, "to", dest)
	srcStat, statErr := os.stat(src, context.allocator)
	if statErr != nil {
		fmt.println("file not found (or other error): ", src)
		return false
	}
	defer os.file_info_delete(srcStat, context.allocator)

	os.remove_all(dest)

	if srcStat.type == .Directory {
		os.make_directory_all(dest)
		err := os.copy_directory_all(dest, src)
		if err != nil {
			log.fatal("couldn't copy directory", src, "to", dest)
			return false
		}
	} else {
		parentDir := os.dir(dest)
		os.make_directory_all(parentDir)
		err := os.copy_file(dest, src)
		if err != nil {
			log.fatal("couldn't copy file", src, "to", dest)
		}
	}

	return true
}

restore :: proc(src: string, dest: string) {
	log.info("restoring from", src, "to", dest)
	sync(src, dest)
}

collect :: proc(src: string, dest: string) {
	log.info("collecting to", src, "from", dest)
	sync(dest, src)
}

indir :: proc(dir: string, subcommand: SubCommand) -> Error {
	home, homeDirError := os.user_home_dir(context.allocator)
	defer delete(home)

	configPath := strings.concatenate([]string{"tomlinks.ini"})
	defer delete(configPath)

	m, err, ok := ini.load_map_from_path(configPath, context.allocator)
	defer ini.delete_map(m)
	if (ok) {
		for sect, dict in m {
			for src, dest0 in dict {
				fmt.println(src)
				dest, was_alloc := strings.replace_all(dest0, "~", home)
				defer if was_alloc { delete(dest) }
				
				if (subcommand == .Collect) {
					collect(src, dest)
				} else {
					restore(src, dest)
				}
			}
		}
	}

	return nil
}

help :: proc() {
fmt.println(
`tomlinks - backup software

This will restore files from package to specified
destinations:
tomlinks restore path-to-backup-dir

This will collect files from destinations to backup package:
tomlinks collect path-to-backup-dir

You can also specify multiple directories with
backup packages:
tomlinks restore path1 path2 path3

What is backup package?
Backup package is directory with tomlinks.ini file.
it just contains keys and values with no sections, keys
are source files or directories, values are destination,
like that:

./local/path/some.conf = ~/.some.conf
another-local-path/dir = ~/.config/dir
`)
}

get_subcommand :: proc() -> SubCommand {
	log.debug("extracting subcommand")
	if len(os.args) < 2 { return .Help }
	switch os.args[1] {
		case "restore":
			return .Restore
		case "collect":
			return .Collect
		case:
			return .Help
	}
}

main :: proc() {
	context.logger = log.create_console_logger()
	log.info("initializing tomlinks")
	cwd := os.get_working_directory(context.allocator) or_else ""
	subcommand := get_subcommand()

	if (subcommand == .Help) {
		help()
		return
	}

	for arg in os.args[2:] {
		os.change_directory(arg)
		indir(arg, subcommand)
		os.change_directory(cwd)
	}
}
