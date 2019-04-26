## HRColorPicker  
***HRColorPicker*** is a lightweight color picker for iOS  
that's easy to use for both users and developers.  

<a href="http://hayashi311.github.io/Color-Picker-for-iOS/" target="_blank"><img src="https://raw.githubusercontent.com/hayashi311/Color-Picker-for-iOS/screenshot/Vimeo.png" alt="Video" style="max-width:100%;"></a>

### Try HRColorPicker
To try HRColorPicker, open Terminal.app and enter the following command:  

    $ pod try Color-Picker-for-iOS

![](https://raw.githubusercontent.com/hayashi311/Color-Picker-for-iOS/screenshot/screen_shot2.png)

### How to use it

#### Podfile

    platform :ios, '7.0'
    pod "Color-Picker-for-iOS", "~> 2.0"

#### Install

    $ pod install

#### Usage

    colorPickerView = [[HRColorPickerView alloc] init];
    colorPickerView.color = self.color;
    [colorPickerView addTarget:self
                        action:@selector(action:)
              forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:colorPickerView];
  
HRColorPicker is optimized for ***Interface Builder*** and ***AutoLayout***.

### How to customize

#### Interface Builder
Layout, color, and tile size can be changed only through the Interface Builder.

![](https://raw.githubusercontent.com/hayashi311/Color-Picker-for-iOS/screenshot/IB.png)

#### Without Interface Builder
As shown below, you can also programmatically customize HRColorPicker.

    colorPickerView.colorMapView.saturationUpperLimit = @1;

If you would like to change the layout, it is strongly recommended that you use the Interface Builder and AutoLayout.

### Changing the UI components

If you would like to customize the user interface, HRColorPicker allows you to completely change out certain UI components.

    @property (nonatomic, strong) IBOutlet UIView <HRColorInfoView> *colorInfoView;
    @property (nonatomic, strong) IBOutlet UIControl <HRColorMapView> *colorMapView;
    @property (nonatomic, strong) IBOutlet UIControl <HRBrightnessSlider> *brightnessSlider;

Create your custom UI class that implement protocol methods.

    YourAwesomeBrightnessSlider *slider = [[YourAwesomeBrightnessSlider alloc] init];
    [colorPickerView addSubview:slider];
    colorPickerView.brightnessSlider = slider;

### Lisence

- new BSD License 


### Requirement
- iOS7.x~
  
