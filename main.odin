package main

import "core:encoding/ini"
import "core:fmt"

import "core:os"
import "core:strings"


Error :: enum {
	None = 0
}

restore :: proc(src: string, dest: string) {
	fmt.println(src)
	fmt.println(dest)
}

indir :: proc(dir: string) -> Error {
	configPath := strings.concatenate([]string{dir, "/", "tomlinks.ini"})
	defer delete(configPath)

	m, err, ok := ini.load_map_from_path(configPath, context.allocator)
	defer ini.delete_map(m)
	if (ok) {
		for sect, dict in m {
			for k, dest in dict {
				src := strings.concatenate([]string{dir, "/", k})
				defer delete(src)
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
