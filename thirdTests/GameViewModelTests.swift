//
//  GameViewModelTests.swift
//  thirdTests
//
//  Tests for GameViewModel using mock dependencies.
//  No real UserDefaults, JSON files, or file system access needed.
//

import Testing
@testable import third

// MARK: - Helpers

private func makeViewModel(
    initialState: GameState = GameState(),
    provider: MockQuestionProvider = MockQuestionProvider(),
    stats: MockStatsManager = MockStatsManager(),
    onStateChanged: @escaping (GameState) -> Void = { _ in },
    onRestartRequested: @escaping () -> Void = {}
) -> GameViewModel {
    GameViewModel(
        initialGameState: initialState,
        isNewGame: true,
        questionProvider: provider,
        statsManager: stats,
        onGameStateChanged: onStateChanged,
        onRestartRequested: onRestartRequested
    )
}

// MARK: - Suite

@Suite("GameViewModel")
struct GameViewModelTests {

    // MARK: - Initial State

    @Test func initialState_isPlaying() {
        let vm = makeViewModel()
        #expect(vm.viewStatus == .playing)
        #expect(vm.gameState.lives == 3)
        #expect(vm.gameState.totalScore == 0)
        #expect(vm.gameState.currentQuestionIndex == 1)
        #expect(vm.inputText == "")
        #expect(vm.lastQuestionScore == 0)
    }

    // MARK: - submitAnswer: empty input

    @Test func submitAnswer_emptyInput_noStateChange() {
        let provider = MockQuestionProvider()
        provider.questionsToReturn = [MockQuestionProvider.makeQuestion()]
        let vm = makeViewModel(provider: provider)

        vm.inputText = "   "
        vm.submitAnswer()

        #expect(vm.gameState.lives == 3)
        #expect(vm.viewStatus == .playing)
    }

    // MARK: - submitAnswer: target answer

    @Test func submitAnswer_targetAnswer_setsQuestionWon() {
        let provider = MockQuestionProvider()
        let question = MockQuestionProvider.makeQuestion(targetKeyword: "hedef")
        provider.questionsToReturn = [question, question]
        let vm = makeViewModel(provider: provider)

        vm.inputText = "hedef"
        vm.submitAnswer()

        #expect(vm.viewStatus == .questionWon)
    }

    @Test func submitAnswer_targetAnswer_addsScoreToTotal() {
        let provider = MockQuestionProvider()
        let question = MockQuestionProvider.makeQuestion(targetKeyword: "hedef")
        provider.questionsToReturn = [question, question]
        let vm = makeViewModel(provider: provider)

        vm.inputText = "hedef"
        vm.submitAnswer()

        // Base score at 0 lives used = 300, multiplier at question 1 = 1.0 → score = 300
        #expect(vm.gameState.totalScore == 300)
        #expect(vm.lastQuestionScore == 300)
    }

    @Test func submitAnswer_targetAnswer_clearsInput() {
        let provider = MockQuestionProvider()
        let question = MockQuestionProvider.makeQuestion(targetKeyword: "hedef")
        provider.questionsToReturn = [question, question]
        let vm = makeViewModel(provider: provider)

        vm.inputText = "hedef"
        vm.submitAnswer()

        #expect(vm.inputText == "")
    }

    @Test func submitAnswer_targetAnswer_sendsTargetAnimationSignal() {
        let provider = MockQuestionProvider()
        let question = MockQuestionProvider.makeQuestion(targetKeyword: "hedef")
        provider.questionsToReturn = [question, question]
        let vm = makeViewModel(provider: provider)

        vm.inputText = "hedef"
        vm.submitAnswer()

        #expect(vm.animationSignal.event == .target)
    }

    // MARK: - submitAnswer: normal answer

    @Test func submitAnswer_normalAnswer_decrementsLives() {
        let provider = MockQuestionProvider()
        let question = MockQuestionProvider.makeQuestion(normalKeyword: "normal")
        provider.questionsToReturn = [question]
        let vm = makeViewModel(provider: provider)

        vm.inputText = "normal"
        vm.submitAnswer()

        #expect(vm.gameState.lives == 2)
    }

    @Test func submitAnswer_normalAnswer_revealsAnswer() {
        let provider = MockQuestionProvider()
        let question = MockQuestionProvider.makeQuestion(normalKeyword: "normal")
        provider.questionsToReturn = [question]
        let vm = makeViewModel(provider: provider)

        vm.inputText = "normal"
        vm.submitAnswer()

        let revealed = vm.question.answers.filter { $0.isRevealed }
        #expect(revealed.count == 1)
        #expect(revealed.first?.displayWord == "Normal")
    }

    @Test func submitAnswer_normalAnswer_sendsWrongAnswerSignal() {
        let provider = MockQuestionProvider()
        let question = MockQuestionProvider.makeQuestion(normalKeyword: "normal")
        provider.questionsToReturn = [question]
        let vm = makeViewModel(provider: provider)

        vm.inputText = "normal"
        vm.submitAnswer()

        #expect(vm.animationSignal.event == .wrongAnswer)
    }

    // MARK: - submitAnswer: wrong text (not in any keyword list)

    @Test func submitAnswer_wrongText_decrementsLives() {
        let provider = MockQuestionProvider()
        provider.questionsToReturn = [MockQuestionProvider.makeQuestion()]
        let vm = makeViewModel(provider: provider)

        vm.inputText = "yanliskelime"
        vm.submitAnswer()

        #expect(vm.gameState.lives == 2)
    }

    @Test func submitAnswer_wrongText_clearsInput() {
        let provider = MockQuestionProvider()
        provider.questionsToReturn = [MockQuestionProvider.makeQuestion()]
        let vm = makeViewModel(provider: provider)

        vm.inputText = "yanliskelime"
        vm.submitAnswer()

        #expect(vm.inputText == "")
    }

    // MARK: - Game over: lives reach 0

    @Test func submitAnswer_threeWrongAnswers_setsLost() {
        let provider = MockQuestionProvider()
        provider.questionsToReturn = [MockQuestionProvider.makeQuestion()]
        let stats = MockStatsManager()
        let vm = makeViewModel(provider: provider, stats: stats)

        vm.inputText = "yanlis1"; vm.submitAnswer()
        vm.inputText = "yanlis2"; vm.submitAnswer()
        vm.inputText = "yanlis3"; vm.submitAnswer()

        #expect(vm.viewStatus == .lost)
    }

    @Test func submitAnswer_threeWrongAnswers_savesStatsOnce() {
        let provider = MockQuestionProvider()
        provider.questionsToReturn = [MockQuestionProvider.makeQuestion()]
        let stats = MockStatsManager()
        let vm = makeViewModel(provider: provider, stats: stats)

        vm.inputText = "yanlis1"; vm.submitAnswer()
        vm.inputText = "yanlis2"; vm.submitAnswer()
        vm.inputText = "yanlis3"; vm.submitAnswer()

        #expect(stats.saveCalls.count == 1)
    }

    // MARK: - submitAnswer: trap answer

    @Test func submitAnswer_trapAnswer_setsLivesToZero() {
        let provider = MockQuestionProvider()
        let question = MockQuestionProvider.makeQuestion(trapKeyword: "tuzak")
        provider.questionsToReturn = [question]
        let stats = MockStatsManager()
        let vm = makeViewModel(provider: provider, stats: stats)

        vm.inputText = "tuzak"
        vm.submitAnswer()

        #expect(vm.gameState.lives == 0)
    }

    @Test func submitAnswer_trapAnswer_saveStats() {
        let provider = MockQuestionProvider()
        let question = MockQuestionProvider.makeQuestion(trapKeyword: "tuzak")
        provider.questionsToReturn = [question]
        let stats = MockStatsManager()
        let vm = makeViewModel(provider: provider, stats: stats)

        vm.inputText = "tuzak"
        vm.submitAnswer()

        #expect(stats.saveCalls.count == 1)
    }

    @Test func submitAnswer_trapAnswer_sendsTrapAnimationSignal() {
        let provider = MockQuestionProvider()
        let question = MockQuestionProvider.makeQuestion(trapKeyword: "tuzak")
        provider.questionsToReturn = [question]
        let vm = makeViewModel(provider: provider)

        vm.inputText = "tuzak"
        vm.submitAnswer()

        #expect(vm.animationSignal.event == .trap)
    }

    // MARK: - nextQuestion

    @Test func nextQuestion_incrementsQuestionIndex() {
        let provider = MockQuestionProvider()
        let q = MockQuestionProvider.makeQuestion()
        provider.questionsToReturn = [q, q]
        let vm = makeViewModel(provider: provider)

        vm.nextQuestion()

        #expect(vm.gameState.currentQuestionIndex == 2)
    }

    @Test func nextQuestion_resetsLives() {
        let provider = MockQuestionProvider()
        let q = MockQuestionProvider.makeQuestion(normalKeyword: "normal")
        provider.questionsToReturn = [q, q]
        let vm = makeViewModel(provider: provider)

        // Lose a life first
        vm.inputText = "normal"; vm.submitAnswer()
        #expect(vm.gameState.lives == 2)

        vm.nextQuestion()

        #expect(vm.gameState.lives == 3)
    }

    @Test func nextQuestion_resetsViewStatusToPlaying() {
        let provider = MockQuestionProvider()
        let q = MockQuestionProvider.makeQuestion(targetKeyword: "hedef")
        provider.questionsToReturn = [q, q]
        let vm = makeViewModel(provider: provider)

        vm.inputText = "hedef"; vm.submitAnswer()
        #expect(vm.viewStatus == .questionWon)

        vm.nextQuestion()

        #expect(vm.viewStatus == .playing)
    }

    @Test func nextQuestion_sendsNextQuestionAnimationSignal() {
        let provider = MockQuestionProvider()
        let q = MockQuestionProvider.makeQuestion()
        provider.questionsToReturn = [q, q]
        let vm = makeViewModel(provider: provider)

        vm.nextQuestion()

        #expect(vm.animationSignal.event == .nextQuestion)
    }

    // MARK: - restartGame

    @Test func restartGame_resetsScore() {
        let provider = MockQuestionProvider()
        let q = MockQuestionProvider.makeQuestion(targetKeyword: "hedef")
        provider.questionsToReturn = [q, q, q]
        var restartCalled = false
        let vm = makeViewModel(provider: provider, onRestartRequested: { restartCalled = true })

        vm.inputText = "hedef"; vm.submitAnswer()
        #expect(vm.gameState.totalScore > 0)

        vm.restartGame()

        #expect(vm.gameState.totalScore == 0)
        #expect(restartCalled)
    }

    @Test func restartGame_resetsViewStatusToPlaying() {
        let provider = MockQuestionProvider()
        let q = MockQuestionProvider.makeQuestion()
        provider.questionsToReturn = [q, q]
        let vm = makeViewModel(provider: provider)

        // Force game over
        vm.inputText = "yanlis1"; vm.submitAnswer()
        vm.inputText = "yanlis2"; vm.submitAnswer()
        vm.inputText = "yanlis3"; vm.submitAnswer()
        #expect(vm.viewStatus == .lost)

        vm.restartGame()

        #expect(vm.viewStatus == .playing)
    }

    @Test func restartGame_callsOnRestartRequested() {
        let provider = MockQuestionProvider()
        let q = MockQuestionProvider.makeQuestion()
        provider.questionsToReturn = [q, q]
        var called = false
        let vm = makeViewModel(provider: provider, onRestartRequested: { called = true })

        vm.restartGame()

        #expect(called)
    }

    // MARK: - calculateScore

    @Test func calculateScore_zeroLivesUsed_returns300ForFirstQuestion() {
        let vm = makeViewModel()
        // Fresh state: livesUsedThisQuestion = 0, currentQuestionIndex = 1
        let score = vm.calculateScore()
        // baseScore[0] = 300, multiplier = 1.0 + (1-1)*0.1 = 1.0
        #expect(score == 300)
    }

    @Test func calculateScore_oneLiveUsed_returns200() {
        var state = GameState()
        state.livesUsedThisQuestion = 1
        let vm = makeViewModel(initialState: state)
        // baseScore[1] = 200, multiplier = 1.0
        #expect(vm.calculateScore() == 200)
    }

    @Test func calculateScore_twoLivesUsed_returns100() {
        var state = GameState()
        state.livesUsedThisQuestion = 2
        let vm = makeViewModel(initialState: state)
        // baseScore[2] = 100, multiplier = 1.0
        #expect(vm.calculateScore() == 100)
    }

    @Test func calculateScore_threeLivesUsed_returnsZero() {
        var state = GameState()
        state.livesUsedThisQuestion = 3
        let vm = makeViewModel(initialState: state)
        // baseScore[3] = 0
        #expect(vm.calculateScore() == 0)
    }

    @Test func calculateScore_multiplierIncreasesWithQuestionIndex() {
        var state = GameState()
        state.currentQuestionIndex = 3  // multiplier = 1.0 + 2*0.1 = 1.2
        let vm = makeViewModel(initialState: state)
        // 300 * 1.2 = 360
        #expect(vm.calculateScore() == 360)
    }

    // MARK: - Stats proxy

    @Test func highScore_proxiedFromStatsManager() {
        let stats = MockStatsManager()
        stats.highScore = 9999
        let vm = makeViewModel(stats: stats)
        #expect(vm.highScore == 9999)
    }

    @Test func furthestQuestion_proxiedFromStatsManager() {
        let stats = MockStatsManager()
        stats.furthestQuestion = 42
        let vm = makeViewModel(stats: stats)
        #expect(vm.furthestQuestion == 42)
    }

    // MARK: - onGameStateChanged callback

    @Test func submitAnswer_targetAnswer_callsOnGameStateChanged() {
        let provider = MockQuestionProvider()
        let q = MockQuestionProvider.makeQuestion(targetKeyword: "hedef")
        provider.questionsToReturn = [q, q]
        var receivedState: GameState?
        let vm = makeViewModel(provider: provider, onStateChanged: { receivedState = $0 })

        vm.inputText = "hedef"
        vm.submitAnswer()

        #expect(receivedState != nil)
        #expect(receivedState!.totalScore == 300)
    }
}
