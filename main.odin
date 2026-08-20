package main

import "core:encoding/ini"
import "core:fmt"

import "core:os"
import "core:strings"


Error :: enum {
	None = 0,
	Some
}

restore :: proc(src: string, dest: string) {
	fmt.println(dest)
	os.remove_all(dest)

}

indir :: proc(dir: string) -> Error {
	home, homeDirError := os.user_home_dir(context.allocator)
	defer delete(home)

	configPath := strings.concatenate([]string{dir, "/", "tomlinks.ini"})
	defer delete(configPath)

	m, err, ok := ini.load_map_from_path(configPath, context.allocator)
	defer ini.delete_map(m)
	if (ok) {
		for sect, dict in m {
			for k, &dest in dict {
				src := strings.concatenate([]string{dir, "/", k})
				defer delete(src)
				dest, was_alloc := strings.replace_all(dest, "~", home)
				restore(src, dest)
			}
		}
	}

	return nil
}


main :: proc() {
	for arg in os.args[2:] {
		indir(arg)
	}
}
