require "imagemagick"

-- Global configuration
ImageMagick.configure({
    tool = "convert",
    log_file = "photos/imagemagick_commands.log",
    debug = false
})

-- Single file processing
imagemagick("photos/photo.png"):resize("1200x800"):crop("1000x700+50+50"):rotate(45):brightnessContrast("+20x-10")
    :annotate("Sample Text", "0,0,0,0"):colorspace("Gray"):blur(2):flip():output("photos/edited_photo.jpg"):run()

local styles = {}
-- Vintage Effect
function styles.vintage(input, output)
    imagemagick(input)
    :colorspace("Gray") -- Convert to grayscale
    :custom("-fill '#704214' -tint 100") -- Add sepia tone
    :brightnessContrast("-10x-10") -- Reduce brightness and contrast
    :blur(1) -- Add slight blur
    :output(output):run()
end

-- Black and White (Monochrome)
function styles.blackAndWhite(input, output)
    imagemagick(input):colorspace("Gray") -- Convert to grayscale
    :brightnessContrast("+20x20") -- Increase brightness and contrast
    :output(output):run()
end

-- Soft Focus
function styles.softFocus(input, output)
    imagemagick(input):custom("-region 70% -blur 0x8") -- Blur edges
    :output(output):run()
end

-- HDR Effect
function styles.hdrEffect(input, output)
    imagemagick(input):custom("-sharpen 0x3") -- Sharpen the details
    :brightnessContrast("+30x20") -- Increase brightness and contrast
    :output(output):run()
end

-- Vignette
function styles.vignette(input, output)
    imagemagick(input):custom("-vignette 0x8") -- Add vignette effect
    :output(output):run()
end

-- Polaroid Frame
function styles.polaroid(input, output)
    imagemagick(input):custom("-bordercolor white -border 20 -bordercolor black -border 5") -- Add border
    :output(output):run()
end

function styles.pixelate(input, output)
    imagemagick(input):custom("-scale 10% -scale 1000%") -- Downscale and upscale to pixelate
    :output(output):run()
end

function styles.glitch(input, output)
    imagemagick(input):custom("-channel R -roll +10+0 -channel G -roll -10+0 -channel B -roll +0-10"):output(output)
        :run()
end
-- Compress Images (JPEG/PNG)
function styles.compressImage(input, output, quality)
    quality = quality or 85 -- Default quality
    imagemagick(input):custom("-quality " .. quality) -- Set quality level
    :custom("-strip") -- Remove metadata
    :output(output):run()
end

-- Resize for Responsive Design
function styles.resizeResponsive(input, sizes, outputDir)
    for _, size in ipairs(sizes) do
        local output = string.format("%s/%dx%d_%s", outputDir, size.width, size.height, input)
        imagemagick(input):resize(string.format("%dx%d", size.width, size.height)):output(output):run()
    end
end

-- Convert to WebP
function styles.convertToWebP(input, output, quality)
    quality = quality or 85 -- Default quality
    imagemagick(input):custom("-quality " .. quality) -- Set quality level
    :custom("-strip") -- Remove metadata
    :output(output:gsub(".%w+$", ".webp")):run()
end

-- Convert to AVIF
function styles.convertToAVIF(input, output, quality)
    quality = quality or 50 -- AVIF uses a lower quality scale
    imagemagick(input):custom("-quality " .. quality) -- Set quality level
    :custom("-strip") -- Remove metadata
    :output(output:gsub(".%w+$", ".avif")):run()
end

-- Optimize for Retina Displays
function styles.optimizeForRetina(input, output)
    imagemagick(input):resize("200%") -- Double the resolution
    :output(output:gsub(".%w+$", "@2x.%0")):run()
end

-- Strip Metadata
function styles.stripMetadata(input, output)
    imagemagick(input):custom("-strip") -- Remove all metadata
    :output(output):run()
end

-- Progressive JPEG
function styles.progressiveJPEG(input, output, quality)
    quality = quality or 85 -- Default quality
    imagemagick(input):custom("-quality " .. quality):custom("-interlace Plane") -- Enable progressive JPEG
    :output(output):run()
end

-- Apply a vintage effect
styles.vintage("photos/photo.png", "photos/vintage_output.jpg")

-- Convert to black and white
styles.blackAndWhite("photos/photo.png", "photos/bw_output.jpg")

-- Add soft focus
styles.softFocus("photos/photo.png", "photos/soft_focus_output.jpg")

-- Apply an HDR effect
styles.hdrEffect("photos/photo.png", "photos/hdr_output.jpg")

-- Add a vignette
styles.vignette("photos/photo.png", "photos/vignette_output.jpg")

-- Create a Polaroid frame
styles.polaroid("photos/photo.png", "photos/polaroid_output.jpg")
styles.pixelate("photos/photo.png", "photos/pix_output.jpg")
styles.glitch("photos/photo.png", "photos/glitch_output.gif")
styles.compressImage("photos/photo.png", "photos/hero_optimized.jpg", 80)
styles.convertToWebP("photos/photo.png", "photos/webp.jp.webp", 80)
styles.convertToAVIF("photos/photo.png", "photos/webp.jp.avif", 80)
-- styles.optimizeForRetina("photos/photo.png", "photos/webp.jp.png")
styles.stripMetadata("photos/photo.png", "photos/webp.nometa.png")
styles.progressiveJPEG("photos/photo.png", "photos/webp.progressive.jpg")

local responsiveSizes = {{
    width = 320,
    height = 240
}, {
    width = 640,
    height = 480
}, {
    width = 1280,
    height = 960
}}
-- styles.resizeResponsive("photos/photo.png", responsiveSizes, "photos")

-- -- Batch processing
-- imagemagick({"image1.jpg", "image2.jpg", "image3.jpg"})
--     :resize("800x600")
--     :output("output_batch.jpg")
--     :run()
