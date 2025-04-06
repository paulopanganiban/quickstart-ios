# PhotoMaker Image Transformation with Replicate API (Migrated from VertexAI)

This sample demonstrates how to use the Replicate API with the PhotoMaker model to transform images based on text prompts. The implementation has been fully migrated from VertexAI to Replicate.

## Setup

1. Get a Replicate API key from [replicate.com](https://replicate.com/)
2. Replace `"r8_YOUR_API_KEY"` in `PhotoReasoningViewModelTest.swift` with your actual API key
3. Make sure your project includes the Replicate Swift package: https://github.com/replicate/replicate-swift

## How it Works

The sample uses the PhotoMaker model from Replicate to transform images based on text prompts:

1. The user selects an image from their photo library
2. The user enters a text prompt describing the desired transformation
3. The app processes the image and sends it along with the prompt to the Replicate API
4. The API returns transformed images based on the prompt
5. The app displays the transformed images to the user

## Implementation Details

This implementation follows the pattern from the [Replicate SwiftUI guide](https://replicate.com/docs/guides/swiftui) by:

1. Defining a `PhotoMaker` type conforming to the `Predictable` protocol
2. Creating structured inputs and outputs for type safety
3. Using the prediction/wait pattern for better state management

The main workflow is handled by these methods:
- `processSelectedImages()`: Prepares the selected images for submission
- `transformImage()`: The main entry point that coordinates the whole process
- `generateImage()`: Initiates the image generation with Replicate
- `performImageTransformation()`: Handles the API call and processes the results

## API Schema

The PhotoMaker model uses the following parameters (based on the official API schema):

### Required Parameters:
- `input_image`: URL to the source image to transform

### Common Parameters:
- `prompt`: Text description of the desired transformation (from user input)
- `num_steps`: Number of diffusion steps (default: 20)

### Optional Parameters:
- `style_name`: Preset style for the image (default: "Photographic (Default)")
- `negative_prompt`: Things to avoid in generation
- `num_outputs`: Number of images to generate (default: 4)
- `style_strength_ratio`: Strength of the style application (default: 20)
- `guidance_scale`: How closely to follow the prompt (default: 5)
- `seed`: For reproducible results
- `input_image2`, `input_image3`, `input_image4`: Additional reference images
- `disable_safety_checker`: Option to disable safety filters

The output is an array of image URLs.

## Example API Input

```json
{
  "input_image": "https://example.com/image.jpg",
  "prompt": "A photo of a person img",
  "num_steps": 20,
  "style_name": "Photographic (Default)",
  "negative_prompt": "nsfw, lowres, bad anatomy...",
  "num_outputs": 4,
  "style_strength_ratio": 20,
  "guidance_scale": 5
}
```

## Migration Notes

- This implementation has been fully migrated from VertexAI to Replicate's PhotoMaker model
- The UI design and user experience remain largely the same
- Added a dedicated prediction status section to monitor the Replicate API prediction state
- Removed the `reason()` method in favor of more focused methods with clearer responsibilities
- Updated parameter names to match the official API schema (`text_prompt` → `prompt`)

## Notes

- The image transformation might take some time depending on the Replicate API's processing queue
- This example currently uses a public URL, but in a real application, you would need to upload your own images
- For production applications, consider implementing a proper image upload service and using the returned URLs 