# Down

A description of this package.

## Parse Markdown String
```swift
Down.parse("*A* **markdown** string ![prettyImage][www.google.com]")
```

## Render Node
```swift
node.render(with: ARenderer)
```

## Build Node
```swift
buildDocument(
    buildText("...")
    ...
)
```


## Dev

### Import CMark
- update `package.swift` 
    - create `libcmark` target
    - update dependency for main target
    
- run `make all` in cmark
- copy all files from `cmark` > `src` (EXCEPT `main.c`)
- copy `cmark_export.h`, `cmark_version.h` and `config.h` from `cmark` > `build` > `src`


## References
- [down](https://github.com/johnxnguyen/Down)
- [reverse renderer](https://github.com/commonmark/cmark/issues/99)
- [builder](https://github.com/jgm/cmark-lua/blob/master/cmark/builder.lua)
- [github-gfm](https://github.com/github/cmark-gfm)
- [commonmark](https://github.com/commonmark/cmark)

## TODO
- use github-gfm and support strikethrough
