import Danger

let danger = Danger()

SwiftLint.lint(inline: true)

if (danger.git.createdFiles + danger.git.modifiedFiles)
    .contains(where: { $0.starts(with: "Demo") }) {
    SwiftLint.lint(.modifiedAndCreatedFiles(directory: "Demo"),
                   inline: true)
}
