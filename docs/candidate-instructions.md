# FlowOps working session

## Scenario

You recently joined FlowOps as a Senior Full Stack Engineer.

FlowOps helps business customers manage invoices, record payments from the Northstar Pay provider, and extract invoice data from documents. The application is already running. Support, finance, and the on-call rotation have reported several production issues. Your job in this session is to investigate and improve the areas below.

## Timebox

60 minutes.

You are not expected to finish every item. Choose an order based on production impact, leave the codebase in a working state, and be ready to explain what you would do with more time.

## Tasks

1. **Invoice listing performance.** Finance says the invoice list slows down as an account accumulates invoices. Investigate the listing endpoint and improve it without changing the response shape.

2. **Duplicate payment processing.** Northstar Pay retries webhooks. Finance has seen the same successful payment applied more than once. A repeated or overlapping delivery of one event should not apply that cash twice. The invoice status alone is not the financial record. Look at the ledger.

3. **Background job reliability.** Operators sometimes see the same document extracted more than once when workers overlap. Processing should be safe when two jobs claim the same document together, including the recorded extraction work.

4. **Dashboard performance.** The invoice screen becomes sluggish as people filter the page and select rows. Investigate the React dashboard and make a focused improvement.

5. **AI extraction failures.** During provider incidents, document extraction has left incorrect or incomplete records. Timeouts, rate limits, and malformed responses need a safe outcome. Transient failures must be distinguishable from responses that should not be retried, and invalid extraction data must not be stored as a successful result.

6. **Cross-account invoice access.** A user was able to open an invoice that belonged to another company by requesting its id. Close the authorization gap on the API. A change that only hides the invoice in React does not fix the report.

## How to work

- Explore the repository and the architecture note.
- Reproduce the behavior you are changing.
- Explain your hypothesis before or while you change code.
- Keep the fix focused.
- Run the relevant baseline and challenge tests.
- Call out trade-offs, residual risk, and what you would monitor in production.

The baseline suite should pass when you start. The challenge suite describes the reported issues and fails on a fresh checkout. A challenge example should pass because the behavior is fixed, not because the example was removed or weakened.

Useful commands are in the README. The app runs through Docker Compose. Demo requests use `Authorization: Bearer demo-account-{id}`. No OpenAI key is required.

## AI tools

Cursor, GitHub Copilot, Claude, ChatGPT, and similar assistants are allowed.

You still need to:

- Understand the code you keep
- Check suggestions against the existing design and tests
- Explain why a change is correct
- Run the tests that cover the behavior
- Own the final result

## What we will discuss

- How you investigated
- Code quality and whether the change fits the codebase
- API and service boundaries
- Data consistency under retries and overlap
- Tenant safety
- React rendering
- Failure handling for the extraction provider
- How you prioritized the hour
- What you would do next
