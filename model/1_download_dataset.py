"""Download PlantVillage color images and export ImageFolder directories.

The repository snapshot contains metadata and Git-LFS pointers, not always
the image bytes. ``load_dataset`` is the supported Hugging Face path because
it resolves the actual image files. The export is intentionally explicit so
the existing MobileViT trainer can read the result with torchvision.
"""

from pathlib import Path
import re

from datasets import load_dataset


def safe_name(value: str) -> str:
    return re.sub(r'[<>:"/\\|?*]', "_", value)


def export_split(split, output_dir: Path, class_names: list[str]) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    for index, row in enumerate(split):
        class_name = safe_name(class_names[row["label"]])
        class_dir = output_dir / class_name
        class_dir.mkdir(exist_ok=True)
        image = row["image"].convert("RGB")
        image.save(class_dir / f"{index:06d}.jpg", quality=95)
        if (index + 1) % 1000 == 0:
            print(f"  exported {index + 1}/{len(split)} images")


def main() -> None:
    output_dir = Path("./dataset")
    if output_dir.exists() and any(output_dir.iterdir()):
        raise SystemExit(
            f"{output_dir} already exists. Remove it only if you want a fresh export."
        )

    print("Downloading PlantVillage color images (about 2 GB)...")
    dataset = load_dataset("mohanty/PlantVillage", "color")
    class_names = dataset["train"].features["label"].names
    export_split(dataset["train"], output_dir, class_names)
    export_split(dataset["test"], output_dir, class_names)
    print(f"Dataset ready at {output_dir.resolve()}")
    print("Run: python train_mobilevit.py --data_dir ./dataset --epochs 40")


if __name__ == "__main__":
    main()
