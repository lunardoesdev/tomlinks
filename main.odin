package main

import "core:encoding/ini"
import "core:fmt"

import "core:os"
import "core:strings"


indir :: proc(dir: string) {
	configPath := strings.concatenate([]string{dir, "/", "tomlinks.ini"})
	defer delete(configPath)

	m, err, ok := ini.load_map_from_path(configPath, context.allocator)
	defer ini.delete_map(m)
	if (ok) {
		for sect, dict in m {
			for k, v in dict {
				fmt.printf(k)
				fmt.printf(v)
			}
		}
	}
}


main :: proc() {
	for arg in os.args[2:] {
		indir(arg)
	}
}
