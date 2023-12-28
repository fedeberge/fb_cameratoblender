# fb_cameratoblender
A Moho script that exports the camera animation to Blender


Running the script will prompt a window to choose a folder. 
Then it saves the animation data in a json that's compatible with this Blender Addon by adroitwhiz

https://github.com/adroitwhiz/after-effects-to-blender-export


How to install?

-- Download the .lua file and copy it into 
  %your custom content folder&\Moho Pro\Scripts\Menu\3D
  (It works as a tool but I haven't made a icon yet)

-- reload scripts (Ctrl Shift Alt L) or restart Moho

How to use?

In Moho:
-- Once you finish animating in Moho, run the script
-- Choose where to save (don't write a name, the script will save a json with the same name as your moho file)

In Blender:
-- Install adroitwhiz's addon
-- Run it from File > Import > After Effects composition data, converted (.json)
-- Chose your json
-- IMPORTANT! Set the options to the right:
------Scale Factor 1
------Adjust Frame Start/End

That's it. Now you can render whatever you want and then just overlay Moho's characters over Blender's backgrounds

Future updates:
--I want to rewrite the Blender Import addon to work out of the box with this json (and make it lighter)
--I'd like to also be able to export Moho's layers's positions in 3D space
--Figure a way of making it work two-way at first and then between Moho Blender and AE with just one json (and maybe TB Harmony)

Really special thanks to:
SimplSam
David Sandberg (ponysmasher)
