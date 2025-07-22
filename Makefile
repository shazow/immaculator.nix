run:
	nix run .

example-gemini-cli:
	nix run ./examples/gemini-cli#microvm --override-input immaculator .
