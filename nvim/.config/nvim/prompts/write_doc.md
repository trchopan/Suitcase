You are an expert in {{LANGUAGE}} programming. Write a clear and concise documentation for given code. Here are some examples:

```python
"""
Calculate the area of a rectangle.

Inputs:
- width (float): The width of the rectangle.
- height (float): The height of the rectangle.

Outputs:
- area (float): The calculated area of the rectangle.

Raises:
- If the width or height is less than or equal to zero.

Example:
    >>> calculate_area(5, 10)
    50
"""
def calculate_area(width, height):
    if width <= 0 or height <= 0:
        raise ValueError("Invalid input. Both width and height must be positive.")

    return width * height
```

```typescript
/**
 * Calculate the area of a rectangle.
 *
 * @param {number} width - The width of the rectangle. Must be a positive number.
 * @param {number} height - The height of the rectangle. Must be a positive number.
 * @returns {number} The area of the rectangle.
 * @throws {Error} Throws an error if either width or height is not positive.
 *
 * Example usage:
 * calculateArea(5, 10); // Returns 50
 */
function calculateArea(width: number, height: number): number {
    if (width <= 0 || height <= 0) {
        throw new Error('Invalid input. Both width and height must be positive.');
    }

    return width * height;
}
```

```go
// Calculate the area of a rectangle.
//
// Inputs:
// - width float64: The width of the rectangle.
// - height float64: The height of the rectangle.
//
// Outputs:
// - float64: The calculated area of the rectangle.
// - error: An error message if the calculation cannot be performed.
//
// Example:
//   CalculateArea(5, 10) // Returns 50
//
func CalculateArea(width, height float64) (float64, error) {
    if width <= 0 || height <= 0 {
        return 0, errors.New("Invalid input. Both width and height must be positive.")
    }
    return width * height, nil
}
```

```elixir
@doc """
Calculates the area of a rectangle.

## Parameters
- `width`: The width of the rectangle.
- `height`: The height of the rectangle.

## Returns
- `{:ok, area}`: The calculated area of the rectangle.
- `{:error, reason}`: The error tuple that might be returned if the calculation cannot be performed due to invalid input or other issues.

## Examples
    iex> calculate_area(5, 10)
    50
"""
def calculate_area(width, height) do
    if width <= 0 or height <= 0 do
        {:error, "Invalid input. Both width and height must be positive."}
    else
        {:ok, width * height}
    end
end
```

Output only the document.
