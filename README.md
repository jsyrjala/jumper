# jumper

A game written in [Zig](https://ziglang.org/) for the [WASM-4](https://wasm4.org) fantasy console.

Running in https://jsyrjala.github.io/jumper/

![Screenshot](docs/screenshot.png)

## Development
Install Zig: https://ziglang.org/download/

Install WASM-4:
```shell
npm install wasm4
```

Run development server:
```shell
w4 watch
```

For more info about setting up WASM-4, see the [quickstart guide](https://wasm4.org/docs/getting-started/setup?code-lang=zig#quickstart).

## Building

Build the cart by running:

```shell
zig build -Drelease-small=true
```

Then run it with:

```shell
w4 run zig-out/lib/cart.wasm
```
## Bundling

Bundling creates a single all-in-one HTML file that can be deployed to web server.
```shell
w4 bundle --html zig-out/index.html --title Jumper --description "Simple platformer" zig-out/lib/cart.wasm
```

## Links

- [WASM-4 Documentation](https://wasm4.org/docs): Learn more about WASM-4.
- [Zig documentation](https://ziglang.org/documentation/0.9.1/): Learn more about Zig.
