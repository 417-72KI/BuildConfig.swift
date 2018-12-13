import Quick
import Nimble
import Foundation

final class ConfigurationPlistTests: QuickSpec {

    override func spec() {
        let tmpDirectory = productsDirectory.appendingPathComponent("tmp")
        beforeSuite {
            try? FileManager.default.createDirectory(at: tmpDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        afterSuite {
            try? FileManager.default.removeItem(at: tmpDirectory)
        }
        guard #available(macOS 10.13, *) else { return }

        describe("binary") {
            let fooBinary = productsDirectory.appendingPathComponent("configurationPlist")
            context("with environment") {
                context("staging") {
                    let process = Process()
                    process.executableURL = fooBinary
                    process.arguments = [
                        "-e",
                        "staging",
                        "-o",
                        tmpDirectory.path,
                        srcPath.absolute().string
                    ]
                    print(process.arguments ?? [])
                    process.setEnvironmentForTest(tmpDirectory: tmpDirectory)
                    print(process.environment ?? [:])
                    let pipe = Pipe()
                    process.standardOutput = pipe
                    it("success") {
                        expect { try process.run() }.notTo(throwError())
                        process.waitUntilExit()
                        let createdFile = tmpDirectory.appendingPathComponent("Config.plist")
                        expect { FileManager.default.fileExists(atPath: createdFile.path) }.to(beTrue())

                        let createdData = try? Data(contentsOf: createdFile)
                        expect(createdData).notTo(beNil())
                        let expectedData = try? Data(contentsOf: expectedStagingFilePath.url)
                        expect(expectedData).notTo(beNil())

                        if let createdData = createdData, let expectedData = expectedData {
                            do {
                                let actual = try PropertyListSerialization.propertyList(from: createdData, options: [], format: nil) as? NSDictionary
                                expect { actual }.notTo(beNil())
                                let expected = try PropertyListSerialization.propertyList(from: expectedData, options: [], format: nil) as? NSDictionary
                                expect { actual }.to(equal(expected))
                            } catch {
                                fail(error.localizedDescription)
                            }
                        }
                    }
                }
                context("production") {
                    let process = Process()
                    process.executableURL = fooBinary
                    process.arguments = [
                        "-e",
                        "production",
                        "-o",
                        tmpDirectory.path,
                        srcPath.absolute().string
                    ]
                    print(process.arguments ?? [])
                    process.setEnvironmentForTest(tmpDirectory: tmpDirectory)
                    print(process.environment ?? [:])
                    let pipe = Pipe()
                    process.standardOutput = pipe
                    it("success") {
                        expect { try process.run() }.notTo(throwError())
                        process.waitUntilExit()
                        let createdFile = tmpDirectory.appendingPathComponent("Config.plist")
                        expect { FileManager.default.fileExists(atPath: createdFile.path) }.to(beTrue())

                        let createdData = try? Data(contentsOf: createdFile)
                        expect(createdData).notTo(beNil())
                        let expectedData = try? Data(contentsOf: expectedProductionFilePath.url)
                        expect(expectedData).notTo(beNil())

                        if let createdData = createdData, let expectedData = expectedData {
                            do {
                                let actual = try PropertyListSerialization.propertyList(from: createdData, options: [], format: nil) as? NSDictionary
                                expect { actual }.notTo(beNil())
                                let expected = try PropertyListSerialization.propertyList(from: expectedData, options: [], format: nil) as? NSDictionary
                                expect { actual }.to(equal(expected))
                            } catch {
                                fail(error.localizedDescription)
                            }
                        }
                    }
                }
            }
        }
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }
}
