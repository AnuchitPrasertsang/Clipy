import Quick
import Nimble
import Magnet
import Carbon
@testable import Clipy

class HotKeyManagerSpec: QuickSpec {
    override func spec() {

        describe("Migrate HotKey") {

            beforeEach {
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.removeObjectForKey(Constants.UserDefaults.hotKeys)
                defaults.removeObjectForKey(Constants.HotKey.migrateNewKeyCombo)
                defaults.removeObjectForKey(Constants.HotKey.mainKeyCombo)
                defaults.removeObjectForKey(Constants.HotKey.historyKeyCombo)
                defaults.removeObjectForKey(Constants.HotKey.snippetKeyCombo)
                defaults.synchronize()
            }

            it("Migrate default settings") {
                let manager = HotKeyManager()
                expect(manager.mainKeyCombo.value).to(beNil())
                expect(manager.historyKeyCombo.value).to(beNil())
                expect(manager.snippetKeyCombo.value).to(beNil())

                let defaults = NSUserDefaults.standardUserDefaults()

                expect(defaults.boolForKey(Constants.HotKey.migrateNewKeyCombo)).to(beFalse())
                manager.setupDefaultHoyKey()
                expect(defaults.boolForKey(Constants.HotKey.migrateNewKeyCombo)).to(beTrue())

                expect(manager.mainKeyCombo.value).toNot(beNil())
                expect(manager.mainKeyCombo.value?.keyCode).to(equal(9))
                expect(manager.mainKeyCombo.value?.modifiers).to(equal(768))
                expect(manager.mainKeyCombo.value?.doubledModifiers).to(beFalse())
                expect(manager.mainKeyCombo.value?.characters).to(equal("V"))

                expect(manager.historyKeyCombo.value).toNot(beNil())
                expect(manager.historyKeyCombo.value?.keyCode).to(equal(9))
                expect(manager.historyKeyCombo.value?.modifiers).to(equal(4352))
                expect(manager.historyKeyCombo.value?.doubledModifiers).to(beFalse())
                expect(manager.historyKeyCombo.value?.characters).to(equal("V"))

                expect(manager.snippetKeyCombo.value).toNot(beNil())
                expect(manager.snippetKeyCombo.value?.keyCode).to(equal(11))
                expect(manager.snippetKeyCombo.value?.modifiers).to(equal(768))
                expect(manager.snippetKeyCombo.value?.doubledModifiers).to(beFalse())
                expect(manager.snippetKeyCombo.value?.characters).to(equal("B"))
            }

            it("Migrate customize settings") {
                let manager = HotKeyManager()
                expect(manager.mainKeyCombo.value).to(beNil())
                expect(manager.historyKeyCombo.value).to(beNil())
                expect(manager.snippetKeyCombo.value).to(beNil())

                let defaults = NSUserDefaults.standardUserDefaults()
                let defaultKeyCombos: [String: AnyObject] = [Constants.Menu.clip: ["keyCode": 0, "modifiers": 4352],
                                                             Constants.Menu.history: ["keyCode": 9, "modifiers": 768],
                                                             Constants.Menu.snippet: ["keyCode": 11, "modifiers": 4352]]
                defaults.registerDefaults([Constants.UserDefaults.hotKeys: defaultKeyCombos])
                defaults.synchronize()

                expect(defaults.boolForKey(Constants.HotKey.migrateNewKeyCombo)).to(beFalse())
                manager.setupDefaultHoyKey()
                expect(defaults.boolForKey(Constants.HotKey.migrateNewKeyCombo)).to(beTrue())

                expect(manager.mainKeyCombo.value).toNot(beNil())
                expect(manager.mainKeyCombo.value?.keyCode).to(equal(0))
                expect(manager.mainKeyCombo.value?.modifiers).to(equal(4352))
                expect(manager.mainKeyCombo.value?.doubledModifiers).to(beFalse())
                expect(manager.mainKeyCombo.value?.characters).to(equal("A"))

                expect(manager.historyKeyCombo.value).toNot(beNil())
                expect(manager.historyKeyCombo.value?.keyCode).to(equal(9))
                expect(manager.historyKeyCombo.value?.modifiers).to(equal(768))
                expect(manager.historyKeyCombo.value?.doubledModifiers).to(beFalse())
                expect(manager.historyKeyCombo.value?.characters).to(equal("V"))

                expect(manager.snippetKeyCombo.value).toNot(beNil())
                expect(manager.snippetKeyCombo.value?.keyCode).to(equal(11))
                expect(manager.snippetKeyCombo.value?.modifiers).to(equal(4352))
                expect(manager.snippetKeyCombo.value?.doubledModifiers).to(beFalse())
                expect(manager.snippetKeyCombo.value?.characters).to(equal("B"))
            }

        }

        describe("Save HotKey") { 

            beforeEach {
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setBool(true, forKey: Constants.HotKey.migrateNewKeyCombo)
                defaults.removeObjectForKey(Constants.HotKey.mainKeyCombo)
                defaults.removeObjectForKey(Constants.HotKey.historyKeyCombo)
                defaults.removeObjectForKey(Constants.HotKey.snippetKeyCombo)
                defaults.synchronize()
            }

            it("Save key combos") {
                let manager = HotKeyManager()
                let defautls = NSUserDefaults.standardUserDefaults()

                expect(defautls.archiveDataForKey(KeyCombo.self, key: Constants.HotKey.mainKeyCombo)).to(beNil())
                expect(defautls.archiveDataForKey(KeyCombo.self, key: Constants.HotKey.historyKeyCombo)).to(beNil())
                expect(defautls.archiveDataForKey(KeyCombo.self, key: Constants.HotKey.snippetKeyCombo)).to(beNil())

                let mainKeyCombo = KeyCombo(keyCode: 9, carbonModifiers: 768)
                let historyKeyCombo = KeyCombo(doubledCocoaModifiers: .CommandKeyMask)
                let snippetKeyCombo = KeyCombo(keyCode: 0, cocoaModifiers: .ShiftKeyMask)

                manager.mainKeyCombo.value = mainKeyCombo
                manager.historyKeyCombo.value = historyKeyCombo
                manager.snippetKeyCombo.value = snippetKeyCombo

                let savedMainKeyCombo = defautls.archiveDataForKey(KeyCombo.self, key: Constants.HotKey.mainKeyCombo)
                let savedHistoryKeyCombo = defautls.archiveDataForKey(KeyCombo.self, key: Constants.HotKey.historyKeyCombo)
                let savedSnippetKeyCombo = defautls.archiveDataForKey(KeyCombo.self, key: Constants.HotKey.snippetKeyCombo)

                expect(savedMainKeyCombo).toNot(beNil())
                expect(savedMainKeyCombo?.keyCode).to(equal(9))
                expect(savedMainKeyCombo?.modifiers).to(equal(768))
                expect(savedMainKeyCombo?.doubledModifiers).to(beFalse())
                expect(savedMainKeyCombo?.characters).to(equal("V"))

                expect(savedHistoryKeyCombo).toNot(beNil())
                expect(savedHistoryKeyCombo?.keyCode).to(equal(0))
                expect(savedHistoryKeyCombo?.modifiers).to(equal(cmdKey))
                expect(savedHistoryKeyCombo?.doubledModifiers).to(beTrue())
                expect(savedHistoryKeyCombo?.characters).to(equal(""))

                expect(savedSnippetKeyCombo).toNot(beNil())
                expect(savedSnippetKeyCombo?.keyCode).to(equal(0))
                expect(savedSnippetKeyCombo?.modifiers).to(equal(shiftKey))
                expect(savedSnippetKeyCombo?.doubledModifiers).to(beFalse())
                expect(savedSnippetKeyCombo?.characters).to(equal("A"))

                manager.mainKeyCombo.value = nil
                expect(defautls.archiveDataForKey(KeyCombo.self, key: Constants.HotKey.mainKeyCombo)).to(beNil())
            }

        }

        describe("Key comobos") {
            it("Default key combos") {
                let keyCombos = HotKeyManager.defaultHotKeyCombos()
                let mainCombos = keyCombos[Constants.Menu.clip] as? [String: Int]
                let historyCombos = keyCombos[Constants.Menu.history] as? [String: Int]
                let snippetCombos = keyCombos[Constants.Menu.snippet] as? [String: Int]

                expect(mainCombos?["keyCode"]).to(equal(9))
                expect(mainCombos?["modifiers"]).to(equal(768))

                expect(historyCombos?["keyCode"]).to(equal(9))
                expect(historyCombos?["modifiers"]).to(equal(4352))

                expect(snippetCombos?["keyCode"]).to(equal(11))
                expect(snippetCombos?["modifiers"]).to(equal(768))
            }
        }
    }
}