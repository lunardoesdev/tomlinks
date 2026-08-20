package main

import "core:encoding/ini"
import "core:fmt"

import "core:os"
import "core:strings"

SubCommand :: enum {
	Restore = 0,
	Collect
}

Error :: enum {
	None = 0,
	Some
}

restore :: proc(src: string, dest: string) {
	srcStat, statErr := os.stat(src, context.allocator)
	defer os.file_info_delete(srcStat, context.allocator)
	if statErr != nil {
		fmt.println("file not found (or other error): ", src)
		return
	}


	os.remove_all(dest)

	if srcStat.type == .Directory {
		ioerr := os.make_directory_all(dest)
		ioerr = os.copy_directory_all(dest, src)
	} else {
		parentDir := os.dir(dest)
		ioerr := os.make_directory_all(parentDir)
		ioerr = os.copy_file(dest, src)
	}
}

collect :: proc(src: string, dest: string) {
	restore(dest, src)
}

indir :: proc(dir: string) -> Error {
	home, homeDirError := os.user_home_dir(context.allocator)
	defer delete(home)

	configPath := strings.concatenate([]string{"tomlinks.ini"})
	defer delete(configPath)

	m, err, ok := ini.load_map_from_path(configPath, context.allocator)
	defer ini.delete_map(m)
	if (ok) {
		for sect, dict in m {
			for src, &dest in dict {
				fmt.println(src)
				dest, was_alloc := strings.replace_all(dest, "~", home)
				
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

subcommand : SubCommand

main :: proc() {
	cwd := os.get_working_directory(context.allocator) or_else ""

	if os.args[1] == "collect" {
		fmt.println("collect mode")
		subcommand = .Collect
	}
	for arg in os.args[2:] {
		os.change_directory(arg)
		indir(arg)
		os.change_directory(cwd)
	}
}
