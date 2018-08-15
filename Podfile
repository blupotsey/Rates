source 'https://github.com/CocoaPods/Specs.git'
workspace 'Rates'
project 'CurrencyConverter/CurrencyConverter.xcodeproj'
project 'Rates/Rates.xcodeproj'

platform :ios, '10.0'
use_frameworks!

def pods
    pod 'Alamofire', '~> 4.7'
end

target 'CurrencyConverter' do
    project 'CurrencyConverter/CurrencyConverter.xcodeproj'
    pods
end

target 'CurrencyConverterIntegrationTests' do
    project 'CurrencyConverter/CurrencyConverter.xcodeproj'
    pods
end

target 'Rates' do
    project 'Rates/Rates.xcodeproj'
    pods
end