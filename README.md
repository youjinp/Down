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
Document(
    Text("...")
    ...
)
```

## References
- [down](https://github.com/johnxnguyen/Down)
- [reverse renderer](https://github.com/commonmark/cmark/issues/99)
- [builder](https://github.com/jgm/cmark-lua/blob/master/cmark/builder.lua)
- [github-gfm](https://github.com/github/cmark-gfm)
- [commonmark](https://github.com/commonmark/cmark)
- [swiftCommonMark](https://github.com/gonzalezreal/SwiftCommonMark)

## TODO
- use github-gfm and support strikethrough
